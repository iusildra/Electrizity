import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.SQLImplicits
import org.apache.spark.sql.{Dataset, Row}
import org.apache.spark.sql.functions._

object ConsoGazElec extends App {
  val spark = SparkSession.builder
    .master("local[6]")
    .appName("Word Count")
    .getOrCreate()

  val sc = spark.sparkContext
  sc.setLogLevel("ERROR")
  import spark.implicits._

  case class RawConso(
      year: Int,
      region: String,
      dept: String,
      filiere: String,
      conso_agri: Double,
      conso_indus: Double,
      conso_tert: Double,
      conso_resid: Double,
      conso_unknown: Double,
      conso_total: Double,
      habitant_region: Int,
      habitant_dept: Int
  )

  case class Conso(
      year: Int,
      region: String,
      filiere: String,
      conso_agri_hab: Double,
      conso_indus_hab: Double,
      conso_tert_hab: Double,
      conso_resid_hab: Double,
      conso_unknown_hab: Double,
      conso_total_hab: Double
  )

  object Filiere {
    val elec = "Electricite"
    val gaz  = "Gaz"
  }

  val csv = spark.read
    .options(
      Map("header" -> "true", "inferSchema" -> "true", "delimiter" -> ",")
    )
    .csv(
      "/home/lucasn/Projects/Electrizity/computedDatasets/ConsoMWhElecGazENEDIS2011_2021.csv"
    )

  val raw_data = {
    val t0 = System.nanoTime()
    val dataWithDate = csv.map(row => {
      RawConso(
        row.getInt(0),
        row.getString(1),
        row.getString(2),
        row.getString(3),
        row.getDouble(4) * 1e3,
        row.getDouble(5) * 1e3,
        row.getDouble(6) * 1e3,
        row.getDouble(7) * 1e3,
        row.getDouble(8) * 1e3,
        row.getDouble(9) * 1e3,
        row.getInt(10),
        row.getInt(11)
      )
    })
    val t1 = System.nanoTime()
    println("Elapsed time: " + (t1 - t0) / 1000000 + "ms")
    dataWithDate
  }

  val data = {
    raw_data.map(row => {
      Conso(
        row.year,
        row.region,
        row.filiere,
        row.conso_agri / row.habitant_region,
        row.conso_indus / row.habitant_region,
        row.conso_tert / row.habitant_region,
        row.conso_resid / row.habitant_region,
        row.conso_unknown / row.habitant_region,
        row.conso_total / row.habitant_region
      )
    })
  }

  def addAvgSum(ds: Dataset[Conso]): Dataset[Row] = {
    ds.groupBy("year", "region")
      .agg(
        avg("conso_agri_hab").as("avg_conso_agri"),
        avg("conso_indus_hab").as("avg_conso_indus"),
        avg("conso_tert_hab").as("avg_conso_tert"),
        avg("conso_resid_hab").as("avg_conso_resid"),
        avg("conso_unknown_hab").as("avg_conso_unknown"),
        avg("conso_total_hab").as("avg_conso"),
        sum("conso_agri_hab").as("sum_conso_agri"),
        sum("conso_indus_hab").as("sum_conso_indus"),
        sum("conso_tert_hab").as("sum_conso_tert"),
        sum("conso_resid_hab").as("sum_conso_resid"),
        sum("conso_unknown_hab").as("sum_conso_unknown"),
        sum("conso_total_hab").as("sum_conso")
      )
  }

  val avgByYearRegionElec = addAvgSum(data
    .filter(row => row.filiere == Filiere.elec))

  val avgByYearRegionGaz = addAvgSum(data
    .filter(row => row.filiere == Filiere.gaz))

  CSVWriter.writeToCsv(
    "consoByYearRegionElec",
    avgByYearRegionElec
  )

  CSVWriter.writeToCsv(
    "consoByYearRegionGaz",
    avgByYearRegionGaz
  )
}
