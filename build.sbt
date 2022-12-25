val scala2Version = "2.13.9"
lazy val sparkCore = "org.apache.spark" %% "spark-core" % "3.3.1"
lazy val sparkMLlib = "org.apache.spark" %% "spark-mllib" % "3.3.1"

lazy val root = project
  .in(file("."))
  .settings(
    name                                   := "Scala",
    version                                := "0.1.0-SNAPSHOT",
    scalaVersion                           := scala2Version,
    libraryDependencies += "org.scalameta" %% "munit" % "0.7.29" % Test,
    libraryDependencies += "com.lihaoyi" %% "requests" % "0.6.9",
    libraryDependencies += sparkCore,
    libraryDependencies += sparkMLlib
  )
run / javaOptions ++= Seq(
  "java.lang",
  "java.lang.invoke",
  "java.lang.reflect",
  "java.io",
  "java.net",
  "java.nio",
  "java.util",
  "java.util.concurrent",
  "java.util.concurrent.atomic",
  "sun.nio.ch",
  "sun.nio.cs",
  "sun.security.action",
  "sun.util.calendar"
).map(p => s"--add-opens=java.base/$p=ALL-UNNAMED")

run / fork := true