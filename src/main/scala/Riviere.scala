import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.SQLImplicits
import org.apache.spark.sql.{Dataset, Row}

object Riviere {
  val spark = SparkSession.builder
    .master("local[6]")
    .appName("Word Count")
    .getOrCreate()

  val sc = spark.sparkContext
  sc.setLogLevel("ERROR")
  import spark.implicits._

  case class Riviere(
      month: Int,
      year: Int,
      libelle: String,
      debit: Double,
      codecastor: String,
      x: Double,
      y: Double,
      z: Double,
      column1: Int,
      perimetre_juridique: String,
      unite: String,
      point_geo: String
  )

  case class RiviereShort(month: Int, year: Int, libelle: String, debit: Double)

  val csv = spark.read
    .options(
      Map("header" -> "true", "inferSchema" -> "true", "delimiter" -> ";")
    )
    .csv(
      "/home/lucasn/Projects/Electrizity/datasets/EDF/debit-des-rivieres-aux-abords-de-centrales-hydrauliques.csv"
    )

  val data = {
    val t0 = System.nanoTime()
    val dataWithDate = csv.map(row => {
      val date = row.getTimestamp(0).toLocalDateTime()
      RiviereShort(
        date.getMonthValue(),
        date.getYear(),
        row.getString(1),
        row.getDouble(2)
      )
    })
    val t1 = System.nanoTime()
    println("Elapsed time: " + (t1 - t0) / 1000000 + "ms")
    dataWithDate
  }
}

object RiviereAvg extends App {
  val data =
    Riviere.data
      .groupBy("month", "year")
      .avg("debit")
      .withColumnRenamed("avg(debit)", "avg_debit")
      .orderBy("year", "month")

    CSVWriter.writeToCsv("debitRivieresAvg", data)
}

object RiviereSum extends App {
  val data =
    Riviere.data
      .groupBy("month", "year")
      .sum("debit")
      .withColumnRenamed("sum(debit)", "sum_debit")
      .orderBy("year", "month")

  CSVWriter.writeToCsv("debitRivieresSum", data)
}

object RiviereAvgByMonth extends App {
  val data =
    Riviere.data
      .groupBy("month")
      .avg("debit")
      .withColumnRenamed("avg(debit)", "avg_debit")
      .orderBy("month")

  CSVWriter.writeToCsv("debitRivieresAvgByMonth", data)
}

object RiviereSumByMonth extends App {
  val data =
    Riviere.data
      .groupBy("month")
      .sum("debit")
      .withColumnRenamed("sum(debit)", "sum_debit")
      .orderBy("month")

  CSVWriter.writeToCsv("debitRivieresSumByMonth", data)
}

object RiviereAvgByYear extends App {
  val data =
    Riviere.data
      .groupBy("year")
      .avg("debit")
      .withColumnRenamed("avg(debit)", "avg_debit")
      .orderBy("year")

  CSVWriter.writeToCsv("debitRivieresAvgByYear", data)
}

object RiviereSumByYear extends App {
  val data =
    Riviere.data
      .groupBy("year")
      .sum("debit")
      .withColumnRenamed("sum(debit)", "sum_debit")
      .orderBy("year")

  CSVWriter.writeToCsv("debitRivieresSumByYear", data)
}

object Run extends App {
  val t0 = System.nanoTime()
  RiviereAvg.main(Array())
  RiviereSum.main(Array())
  RiviereAvgByMonth.main(Array())
  RiviereSumByMonth.main(Array())
  RiviereAvgByYear.main(Array())
  RiviereSumByYear.main(Array())
  val t1 = System.nanoTime()
  println("Total Elapsed time: " + (t1 - t0) / 1000000 + "ms")
}
