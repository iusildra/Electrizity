import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.SQLImplicits
import org.apache.spark.sql.{Dataset, Row}
import java.sql.Timestamp
import org.apache.spark.sql.SQLContext
import org.apache.spark.sql.functions._

object IndispoProd {
  val spark = SparkSession.builder
    .master("local[6]")
    .appName("Word Count")
    .getOrCreate()

  val sc = spark.sparkContext

  sc.setLogLevel("ERROR")
  import spark.implicits._

  case class Status(
      id: Int,
      libelle: String
  )
  object Status {
    def apply(str: String): Status = str match {
      case "Active"    => Status(1, "Active")
      case "Inactive"  => Status(2, "Inactive")
      case "Supprimée" => Status(3, "Supprimée")
      case "Annulée"   => Status(4, "Annulée")
    }
  }

  case class Kind(
      id: Int,
      libelle: String
  )
  object Kind {
    def apply(str: String): Kind = str match {
      case "Planifiée" => Kind(1, "Planifiée")
      case "Fortuite"  => Kind(2, "Fortuite")
      case "Chronique" => Kind(3, "Chronique")
    }
  }

  case class Sector(
      id: Int,
      libelle: String
  )
  object Sector {
    def apply(str: String): Sector = str match {
      case "Nucléaire"       => Sector(1, "Nucléaire")
      case "Gaz fossile"     => Sector(2, "Gaz fossile")
      case "Fuel / TAC"      => Sector(3, "Fuel / TAC")
      case "Houille fossile" => Sector(4, "Charbon")
      case _                 => Sector(5, "Hydraulique")
    }
  }

  case class Cause(
      id: Int,
      libelle: String
  )

  object Cause extends Enumeration {
    def apply(str: String): Cause = str match {
      case "Maintenance prévisionnelle" => Cause(1, "Maintenance")
      case "Défaillance"                => Cause(2, "Défaillance")
      case "Informations complémentaires" =>
        Cause(3, "Informations complémentaires")
      case "Arrêt / fermeture" => Cause(4, "Arrêt / fermeture")
    }
  }

  case class Indispo(
      id: String,
      status: Status,
      kind: Kind,
      filiere: Sector,
      name: String,
      versionNb: Int,
      publish_date: Timestamp,
      begin: Timestamp,
      end: Timestamp,
      cause: Cause,
      complementaryInfo: String,
      maxPower: Option[Double],
      availablePower: Option[Double]
  )

  case class IndispoShort(
      id: String,
      status: Status,
      kind: Kind,
      filiere: Sector,
      versionNb: Int,
      publish_date: Timestamp,
      begin: Timestamp,
      end: Timestamp,
      cause: Cause,
      maxPower: Option[Double],
      availablePower: Option[Double]
  )

  case class IndispoShortRaw(
      id: String,
      status: String,
      kind: String,
      filiere: String,
      versionNb: Int,
      publish_date: Timestamp,
      begin: Timestamp,
      end: Timestamp,
      cause: String,
      maxPower: Double,
      availablePower: Double
  )

  val csv = spark.read
    .options(
      Map("header" -> "true", "inferSchema" -> "true", "delimiter" -> ";")
    )
    .csv(
      "/home/lucasn/Projects/Electrizity/datasets/EDF/indisponibilites-des-moyens-de-production-edf-sa.csv"
    )

  val raw_data = {
    val t0 = System.nanoTime()
    val parsedData = csv
      .map(row => {
        IndispoShort(
          row.getString(0),
          Status(row.getString(1)),
          Kind(row.getString(2)),
          Sector(row.getString(3)),
          row.getInt(5),
          row.getTimestamp(6),
          row.getTimestamp(7),
          row.getTimestamp(8),
          Cause(row.getString(9)),
          Some(row.getAs[Double](11)),
          Some(row.getAs[Double](12))
        )
      })
      .filter(x => x.maxPower.isDefined && x.availablePower.isDefined)
    val t1 = System.nanoTime()
    println("Elapsed time: " + (t1 - t0) / 1000000 + "ms")
    parsedData
  }

  val data = raw_data
    .map(row =>
      IndispoShortRaw(
        row.id,
        row.status.libelle,
        row.kind.libelle,
        row.filiere.libelle,
        row.versionNb,
        row.publish_date,
        row.begin,
        row.end,
        row.cause.libelle,
        row.maxPower.get / 1e6,
        row.availablePower.get / 1e6
      )
    )
}

object UnavailabilityBySector extends App {

  val tot = IndispoProd.spark

  implicit val stringIntEncoder =
    org.apache.spark.sql.Encoders.tuple(
      org.apache.spark.sql.Encoders.STRING,
      org.apache.spark.sql.Encoders.scalaInt
    )

  val originData = IndispoProd.data

  def getImpact: (Double, Double) => Double =
    (max: Double, available: Double) => max - available
  def extractYear: (Timestamp => Int) = (ts: Timestamp) =>
    ts.toLocalDateTime.getYear

  val lastVersion = originData
    .groupBy("id")
    .agg(max("versionNb").as("versionNb"))
    .as[(String, Int)]
    .collect
    .toMap

  val data = originData
    .filter(row => row.versionNb == lastVersion(row.id))
    .withColumn(
      "impact",
      udf(getImpact).apply(col("maxPower"), col("availablePower"))
    )
    .withColumn("begin", udf(extractYear).apply(col("begin")))

  val countBySectorYear = data
    .groupBy("filiere", "begin")
    .count()

  val sumBySectorYear = data
    .groupBy("filiere", "begin")
    .sum("impact")
    .withColumnRenamed("sum(impact)", "sum_impact")

  // **************
  // * BY SECTOR *
  // **************
  val countBySector = data
    .groupBy("filiere")
    .count()
    .orderBy("count")

  val sumBySector = data
    .groupBy("filiere")
    .sum("impact")
    .withColumnRenamed("sum(impact)", "sum_impact")
    .orderBy("sum_impact")

  val countBySectorAndCause = data
    .groupBy("filiere", "cause")
    .count()
    .orderBy("count")

  val sumBySectorAndCause = data
    .groupBy("filiere", "cause")
    .sum("impact")
    .withColumnRenamed("sum(impact)", "sum_impact")
    .orderBy("sum_impact")

  // ************
  // * BY KIND *
  // ************

  val countByKind = data
    .groupBy("kind")
    .count()
    .orderBy("count")

  val sumByKind = data
    .groupBy("kind")
    .sum("impact")
    .withColumnRenamed("sum(impact)", "sum_impact")
    .orderBy("sum_impact")

  val countByKindAndCause = data
    .groupBy("kind", "cause")
    .count()
    .orderBy("count")

  val sumByKindAndCause = data
    .groupBy("kind", "cause")
    .sum("impact")
    .withColumnRenamed("sum(impact)", "sum_impact")
    .orderBy("sum_impact")

  // **************
  // * BY MIXING *
  // **************

  // For each sector and for each kind, how many unavailabilities are there by cause ?
  val countBySectorAndCauseAndKind = data
    .groupBy("filiere", "cause", "kind")
    .count()
    .orderBy("count")

  // For each sector and for each kind, what is the total impact of unavailabilities by cause ?
  val sumBySectorAndCauseAndKind = data
    .groupBy("filiere", "cause", "kind")
    .sum("impact")
    .withColumnRenamed("sum(impact)", "sum_impact")
    .orderBy("sum_impact")

  CSVWriter.writeToCsv("unavailabilitiesBySectorYearCount", countBySectorYear)
  CSVWriter.writeToCsv("unavailabilitiesBySectorYearSum", sumBySectorYear)

  CSVWriter.writeToCsv("unavailabilityBySectorCount", countBySector)
  CSVWriter.writeToCsv("unavailabilityBySectorSum", sumBySector)
  CSVWriter.writeToCsv("unavailabilityByKindCount", countByKind)
  CSVWriter.writeToCsv("unavailabilityByKindSum", sumByKind)
  CSVWriter.writeToCsv(
    "unavailabilityBySectorCauseCount",
    countBySectorAndCause
  )
  CSVWriter.writeToCsv(
    "unavailabilityBySectorCauseSum",
    sumBySectorAndCause
  )
  CSVWriter.writeToCsv("unavailabilityByKindCauseCount", countByKindAndCause)
  CSVWriter.writeToCsv("unavailabilityByKindCauseSum", sumByKindAndCause)
  CSVWriter.writeToCsv(
    "unavailabilityBySectorCauseKindCount",
    countBySectorAndCauseAndKind
  )
  CSVWriter.writeToCsv(
    "unavailabilityBySectorCauseKindSum",
    sumBySectorAndCauseAndKind
  )
}
