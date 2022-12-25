library(ggplot2)
library(dplyr)
library(hrbrthemes)

add_date <- function(csv_filename) {
  data <- read.csv(csv_filename, header = TRUE, sep = ",") %>%
  mutate(
    date = as.Date(
      paste("01", month, year, sep = "-"),
      format = "%d-%m-%Y"
  ))

  return(data)
}

plotter <- function(data, xVals, yVals, title, xlab, ylab) {
  plt <- ggplot(data, aes(x = xVals, y = yVals)) +
    geom_point() +
    geom_smooth(method = lm, color = "red", fill = "#69b3a2", se = TRUE) +
    labs(
      title =
        title,
      x = xlab,
      y = ylab
    )
  return(plt)
}

avg_my <- add_date("./debitRivieres-avg-MY.csv")
sum_my <- add_date("./debitRivieres-sum-MY.csv")

debit_avg_my <- plotter(
  avg_my, avg_my$date, avg_my$avg_debit,
  "Débit moyen mensuel des rivières aux bords des centrales hydrauliques",
  "Date",
  "Débit (m3/s)"
)

debit_sum_my <- plotter(
  sum_my, sum_my$date, sum_my$sum_debit,
  "Débit total mensuel des rivières aux bords des centrales hydrauliques",
  "Date",
  "Débit (m3/s)"
)

print(debit_avg_my)
print(debit_sum_my)
