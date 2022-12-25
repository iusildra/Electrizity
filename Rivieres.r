library(ggplot2)
library(dplyr)
library(gganimate)
library(gifski)
library(png)

add_fulldate <- function(csv_filename) {
  data <- read.csv(csv_filename, header = TRUE, sep = ",") %>%
    mutate(
      date = as.Date(
        paste("01", month, year, sep = "-"),
        format = "%d-%m-%Y"
      )
    )

  return(data)
}

density_plotter <- function(data) {
  plot <- ggplot(aes(x = data)) +
    geom_density(fill = "#69b3a2", color = "#e9ecef", alpha = 0.8) +
    labs(
      x = "Débit (m3/s)"
    )
  return(plot)
}

plotter <- function(data, x_vals, y_vals, title, xlab, ylab) {
  plt <- ggplot(data, aes(x = x_vals, y = y_vals)) +
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

save_to_file <- function(plt, filename, scale = 1) {
  ggsave(
    filename = filename,
    path = "./plots/",
    scale = scale,
    plot = plt,
    dpi = 300
  )
}

avg_my <- read.csv(
  "./computedDatasets/debitRivieresAvg.csv",
  header = TRUE
)
sum_my <- read.csv(
  "./computedDatasets/debitRivieresSum.csv",
  header = TRUE
)
# avg_m <- read.csv(
#   "./computedDatasets/debitRivieresAvgByMonth.csv",
#   header = TRUE,
#   sep = ",")
# sum_m <- read.csv(
#   "./computedDatasets/debitRivieresSumByMonth.csv",
#   header = TRUE,
#   sep = ",")
# avg_y <- read.csv(
#   "./computedDatasets/debitRivieresAvgByYear.csv",
#   header = TRUE,
#   sep = ",")
# sum_y <- read.csv(
#   "./computedDatasets/debitRivieresSumByYear.csv",
#   header = TRUE,
#   sep = ","
# )

# debit_avg_my <- plotter(
#   avg_my, avg_my$date, avg_my$avg_debit,
#   "Débit moyen par mois & année des rivières aux bords des centrales hydrauliques", # nolint
#   "Date",
#   "Débit (m3/s)"
# )

# debit_sum_my <- plotter(
#   sum_my, sum_my$date, sum_my$sum_debit,
#   "Débit total par mois & année des rivières aux bords des centrales hydrauliques", # nolint
#   "Date",
#   "Débit (m3/s)"
# )

# debit_avg_m <- plotter(
#   avg_m, avg_m$month, avg_m$avg_debit,
#   "Débit moyen mensuel des rivières aux bords des centrales hydrauliques",
#   "Date",
#   "Débit (m3/s)"
# )

# debit_sum_m <- plotter(
#   sum_m, sum_m$month, sum_m$sum_debit,
#   "Débit total mensuel des rivières aux bords des centrales hydrauliques",
#   "Date",
#   "Débit (m3/s)"
# )

# debit_avg_y <- plotter(
#   avg_y, avg_y$year, avg_y$avg_debit,
#   "Débit moyen annuel des rivières aux bords des centrales hydrauliques",
#   "Date",
#   "Débit (m3/s)"
# )

# debit_sum_y <- plotter(
#   sum_y, sum_y$year, sum_y$sum_debit,
#   "Débit total annuel des rivières aux bords des centrales hydrauliques",
#   "Date",
#   "Débit (m3/s)"
# )

density_avg_graph <- avg_my %>%
  ggplot(aes(x = avg_debit)) +
  geom_density(fill = "#69b3a2", color = "#e9ecef", alpha = 0.8) +
  labs(
    title = "Year: {frame_time}",
    x = "Débit (m3/s)"
  ) +
  transition_time(year) +
  ease_aes("linear")

x <- animate(density_avg_graph, fps = 5, renderer = gifski_renderer())

print(x)

# anim_save("densityDistributionByYear.gif")
# save_animation("densityDistributionByYear.gif", density_avg_graph)
# print(density_sum)

# save_to_file(debit_avg_my, "debitRivieresAvg.png", 1)
# save_to_file(debit_avg_m, "debitRivieresAvgByMonth.png", 1)
# save_to_file(debit_avg_y, "debitRivieresAvgByYear.png", 1)
# save_to_file(debit_sum_my, "debitRivieresSum.png", 1)
# save_to_file(debit_sum_m, "debitRivieresSumByMonth.png", 1)
# save_to_file(debit_sum_y, "debitRivieresSumByYear.png", 1)
