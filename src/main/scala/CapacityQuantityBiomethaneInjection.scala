import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.SQLImplicits
import org.apache.spark.sql.{Dataset, Row}
import java.sql.Timestamp
import org.apache.spark.sql.SQLContext
import org.apache.spark.sql.functions._

object CapacityQuantityBiomethaneInjection {
  val spark = SparkSession.builder
    .master("local[6]")
    .appName("Word Count")
    .getOrCreate()

  val sc = spark.sparkContext

  sc.setLogLevel("ERROR")
  import spark.implicits._

  case class CsvRow(
      year: Int,
      region: String,
      regionInseeCode: Int,
      department: String,
      departmentInseeCode: Int,
      epci: String,
      epciInseeCode: Int,
      municipality: String,
      municipalityInseeCode: Int,
      mainTown: String,
      mainTownInseeCode: Int,
      plantName: String,
      typology: String,
      dateFirstInjection: String,
      injectionCapacity: Int,
      totalPower: Double,
      geolocation: String
  )

  // TODO : year-region-department injection capacity & total power
  // TODO : year-typology injection capacity & total power
  // TODO : year-region-department-typology injection capacity & total power
  val csv = spark.read
    .options(
      Map("header" -> "true", "inferSchema" -> "true", "delimiter" -> ";")
    )
    .csv(
      "/home/lucasn/Projects/Electrizity/datasets/GRDF/capacite-et-quantite-dinjection-de-biomethane.csv"
    )

  val raw_data = csv.map(row => {
    CsvRow(
      row.getInt(0),
      row.getString(1),
      row.getInt(2),
      row.getString(3),
      row.getInt(4),
      row.getString(5),
      row.getInt(6),
      row.getString(7),
      row.getInt(8),
      row.getString(9),
      row.getInt(10),
      row.getString(11),
      row.getString(12),
      row.getString(13),
      row.getInt(14),
      row.getDouble(15) / 1e3,
      row.getString(17)
    )
  })
}

object Biomethane extends App {

  implicit val stringIntEncoder =
    org.apache.spark.sql.Encoders.STRING

  val data = CapacityQuantityBiomethaneInjection.raw_data

  val yearRegion = data
    .groupBy("year", "region")
    .agg(
      avg("totalPower").as("avgTotalPower"),
      sum("totalPower").as("sumTotalPower")
    )

  val typology = data
    .groupBy("year", "typology")
    .agg(
      avg("totalPower").as("avgTotalPower"),
      sum("totalPower").as("sumTotalPower")
    )

  val yearRegionTypology = data
    .groupBy("year", "region", "typology")
    .agg(
      avg("totalPower").as("avgTotalPower"),
      sum("totalPower").as("sumTotalPower")
    )

  CSVWriter.writeToCsv(
    "biomethane-yearRegion",
    yearRegion
  )

  CSVWriter.writeToCsv(
    "biomethane-yearTypology",
    typology
  )

  CSVWriter.writeToCsv(
    "biomethane-yearRegionTypology",
    yearRegionTypology
  )
}
