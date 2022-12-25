import org.apache.hadoop.fs.{Path, FileUtil, FileSystem}
import org.apache.hadoop.conf.Configuration
import org.apache.spark.sql.{Dataset, Row}
import java.io.File

object CSVWriter {
  val hadoopConfig = new Configuration()
  val hdfs         = FileSystem.get(hadoopConfig)

  def merge(srcPath: String, dstPath: String): Unit = {
    val src  = new Path(srcPath)
    val dest = new Path(dstPath)
    val srcFile = FileUtil
      .listFiles(new File(srcPath))
      .filter(f => f.getPath.endsWith(".csv"))
      .map(f => f.getName())
      .apply(0)
      
    hdfs.copyFromLocalFile(new Path(srcPath + "/" + srcFile), dest)
    hdfs.delete(
      new Path("computedDatasets/." + dstPath.split("/")(1) + ".crc"),
      true
    )
    hdfs.delete(src, true)
  }

  def writeToCsv(fileName: String, ds: Dataset[Row]) = {
    hdfs.delete(
      new Path("computedDatasets/" + fileName + ".csv"),
      true
    )
    val output = "computedDatasetsTemp/" + fileName
    ds
      .coalesce(1)
      .write
      .mode("overwrite")
      .format("csv")
      .option("header", "true")
      .save(output)
    merge(output, "computedDatasets/" + fileName + ".csv")
    ds.unpersist()
  }
}
