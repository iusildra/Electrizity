library(ggplot2)
library(dplyr)
library(hrbrthemes)
library(RColorBrewer)

plotter2 <- function(data, x_vals, y_vals, title, xlab, ylab) {
  plt <- ggplot(data, aes(x = x_vals, y = y_vals)) +
    geom_bar(stat = "identity") +
    theme(legend.position = "none") +
    labs(
      title = title,
      x = xlab,
      y = ylab
    )
  return(plt)
}

plotter3 <- function(data, x_vals, y_vals, color, color_name, title, xlab, ylab) {
  plt <- ggplot(data, aes(x = x_vals, y = y_vals, fill = color)) +
    geom_bar(position = "stack", stat = "identity") +
    labs(
      title = title,
      x = xlab,
      y = ylab,
      fill = color_name
    )
  return(plt)
}

plotter4 <- function(data, group, x_vals, y_vals, fill, fill_name, title, xlab, ylab) {
  new_group <- unique(as.factor(group))
  plt <- ggplot(data, aes(x = x_vals, y = y_vals, fill = fill)) +
    geom_bar(position = "dodge", stat = "identity") +
    facet_wrap(new_group) +
    labs(
      title = title,
      x = xlab,
      y = ylab,
      fill = fill_name
    ) +
    theme(legend.position = "bottom")
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

indi_count <- read.csv(
  "./computedDatasets/unavailabilitiesBySectorYearCount.csv",
  header = TRUE,
  sep = ","
)
indi_sum <- read.csv(
  "./computedDatasets/unavailabilitiesBySectorYearSum.csv",
  header = TRUE,
  sep = ","
)

indi_sector_count <- read.csv(
  "./computedDatasets/unavailabilityBySectorCount.csv",
  header = TRUE,
  sep = ","
)
indi_sector_sum <- read.csv(
  "./computedDatasets/unavailabilityBySectorSum.csv",
  header = TRUE,
  sep = ","
)
indi_kind_count <- read.csv(
  "./computedDatasets/unavailabilityByKindCount.csv",
  header = TRUE,
  sep = ","
)
indi_kind_sum <- read.csv(
  "./computedDatasets/unavailabilityByKindSum.csv",
  header = TRUE,
  sep = ","
)
indi_sector_cause_count <- read.csv(
  "./computedDatasets/unavailabilityBySectorCauseCount.csv",
  header = TRUE,
  sep = ","
)
indi_sector_cause_sum <- read.csv(
  "./computedDatasets/unavailabilityBySectorCauseSum.csv",
  header = TRUE,
  sep = ","
)
indi_kind_cause_count <- read.csv(
  "./computedDatasets/unavailabilityByKindCauseCount.csv",
  header = TRUE,
  sep = ","
)
indi_kind_cause_sum <- read.csv(
  "./computedDatasets/unavailabilityByKindCauseSum.csv",
  header = TRUE,
  sep = ","
)
indi_sector_cause_kind_count <- read.csv(
  "./computedDatasets/unavailabilityBySectorCauseKindCount.csv",
  header = TRUE,
  sep = ","
)
indi_sector_cause_kind_sum <- read.csv(
  "./computedDatasets/unavailabilityBySectorCauseKindSum.csv",
  header = TRUE,
  sep = ","
)

indi_sector_count_graph <- plotter2(
  indi_sector_count,
  x_vals = indi_sector_count$filiere,
  y_vals = indi_sector_count$count,
  title = "Indisponibilit?? par secteur",
  xlab = "Secteur",
  ylab = "Nombre d'indisponibilit??s"
)

indi_sector_sum_graph <- plotter2(
  indi_sector_sum,
  x_vals = indi_sector_sum$filiere,
  y_vals = indi_sector_sum$sum,
  title = "Indisponibilit?? par secteur",
  xlab = "Secteur",
  ylab = "Somme des indisponibilit??s (GW)"
)
indi_kind_count_graph <- plotter2(
  indi_kind_count,
  x_vals = indi_kind_count$kind,
  y_vals = indi_kind_count$count,
  title = "Indisponibilit?? par type",
  xlab = "Type",
  ylab = "Nombre d'indisponibilit??s"
)
indi_kind_sum_graph <- plotter2(
  indi_kind_sum,
  x_vals = indi_kind_sum$kind,
  y_vals = indi_kind_sum$sum,
  title = "Indisponibilit?? par type",
  xlab = "Type",
  ylab = "Somme des indisponibilit??s (GW)"
)
indi_sector_cause_count_graph <- plotter3(
  indi_sector_cause_count,
  x_vals = indi_sector_cause_count$filiere,
  y_vals = indi_sector_cause_count$count,
  color = indi_sector_cause_count$cause,
  color_name = "Cause",
  title = "Indisponibilit?? par secteur et cause",
  xlab = "Secteur",
  ylab = "Nombre d'indisponibilit??s"
)
indi_sector_cause_sum_graph <- plotter3(
  indi_sector_cause_sum,
  x_vals = indi_sector_cause_sum$filiere,
  y_vals = indi_sector_cause_sum$sum,
  color = indi_sector_cause_sum$cause,
  color_name = "Cause",
  title = "Indisponibilit?? par secteur et cause",
  xlab = "Secteur",
  ylab = "Somme des indisponibilit??s (GW)"
)
indi_kind_cause_count_graph <- plotter3(
  indi_kind_cause_count,
  x_vals = indi_kind_cause_count$kind,
  y_vals = indi_kind_cause_count$count,
  color = indi_kind_cause_count$cause,
  color_name = "Cause",
  title = "Indisponibilit?? par type et cause",
  xlab = "Type",
  ylab = "Nombre d'indisponibilit??s"
)
indi_kind_cause_sum_graph <- plotter3(
  indi_kind_cause_sum,
  x_vals = indi_kind_cause_sum$kind,
  y_vals = indi_kind_cause_sum$sum,
  color = indi_kind_cause_count$cause,
  color_name = "Cause",
  title = "Indisponibilit?? par type et cause",
  xlab = "Type",
  ylab = "Somme des indisponibilit??s (GW)"
)

# indi_sector_cause_kind_count_graph <- plotter4(
#   indi_sector_cause_kind_count,
#   group = indi_sector_cause_kind_count$filiere,
#   x_vals = indi_sector_cause_kind_count$kind,
#   y_vals = indi_sector_cause_kind_count$count,
#   fill = indi_sector_cause_kind_count$cause,
#   fill_name = "Cause",
#   title = "Indisponibilit?? par secteur, cause et type",
#   xlab = "Secteur",
#   ylab = "Nombre d'indisponibilit??s"
# )
# indi_sector_cause_kind_sum_graph <- plotter4(
#   indi_sector_cause_kind_sum,
#   group = indi_sector_cause_kind_sum$filiere,
#   x_vals = indi_sector_cause_kind_sum$kind,
#   y_vals = indi_sector_cause_kind_sum$sum,
#   fill = indi_sector_cause_kind_sum$cause,
#   fill_name = "Cause",
#   title = "Indisponibilit?? par secteur, cause et type",
#   xlab = "Secteur",
#   ylab = "Somme des indisponibilit??s (GW)"
# )

indi_sector_count_year <- indi_count %>%
  ggplot(aes(x = begin, y = count, group = filiere, color = filiere)) +
  geom_line() +
  labs(
    title = "Indisponibilit?? par secteur et ann??e",
    x = "Ann??e de d??but de l'indisponibilit??",
    y = "Nombre d'indisponibilit??s",
    color = "filiere"
  )

indi_sector_sum_year <- indi_sum %>%
  ggplot(aes(x = begin, y = sum_impact, group = filiere, color = filiere)) +
  geom_line() +
  labs(
    title = "Indisponibilit?? par secteur et ann??e",
    x = "D??but de l'indisponibilit??",
    y = "Somme des indisponibilit??s (GW)",
    color = "filiere"
  )

# print(indi_sector_count_year)
# print(indi_sector_sum_year)
# print(indi_sector_count_graph)
# print(indi_sector_sum_graph)
# print(indi_kind_count_graph)
# print(indi_kind_sum_graph)
# print(indi_sector_cause_count_graph)
# print(indi_sector_cause_sum_graph)
# print(indi_kind_cause_count_graph)
# print(indi_kind_cause_sum_graph)
# print(indi_sector_cause_kind_count_graph)
# print(indi_sector_cause_kind_sum_graph)


# save_to_file(indi_sector_count_year, "unavailabilityBySectorYearCount.png", 1)
# save_to_file(indi_sector_count_graph, "unavailabilityBySectorCount.png", 1)
# save_to_file(indi_sector_sum_graph, "unavailabilityBySectorSum.png", 1)
# save_to_file(indi_kind_count_graph, "unavailabilityByKindCount.png", 1)
# save_to_file(indi_kind_sum_graph, "unavailabilityByKindSum.png", 1)
# save_to_file(indi_sector_cause_count_graph, "unavailabilityBySectorCauseCount.png", 1)
# save_to_file(indi_sector_cause_sum_graph, "unavailabilityBySectorCauseSum.png", 1)
# save_to_file(indi_kind_cause_count_graph, "unavailabilityByKindCauseCount.png", 1)
# save_to_file(indi_kind_cause_sum_graph, "unavailabilityByKindCauseSum.png", 1)
# save_to_file(indi_sector_cause_kind_count_graph, "unavailabilityBySectorCauseKindCount.png", 1)
# save_to_file(indi_sector_cause_kind_sum_graph, "unavailabilityBySectorCauseKindSum.png", 1)
