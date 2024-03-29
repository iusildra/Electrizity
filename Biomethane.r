library(ggplot2)
library(dplyr)
library(hrbrthemes)
library(RColorBrewer)

plotter2 <- function(data, x_vals, y_vals, title, xlab, ylab) {
  plt <- ggplot(data, aes(x = x_vals, y = y_vals)) +
    geom_point() +
    geom_line() +
    theme(legend.position = "none") +
    labs(
      title = title,
      x = xlab,
      y = ylab
    )
  return(plt)
}

plotter3 <- function(data, x_vals, y_vals, color, color_name, title, xlab, ylab) {
  plt <- ggplot(data, aes(x = x_vals, y = y_vals, group = color, color = color)) +
    geom_point() +
    geom_line() +
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

biomethane_typology <- read.csv(
  "./computedDatasets/biomethane-yearTypology.csv",
  header = TRUE,
  sep = ","
)

biomethane_year_region <- read.csv(
  "./computedDatasets/biomethane-yearRegion.csv",
  header = TRUE,
  sep = ","
)

biomethane_year_region_typo <- read.csv(
  "./computedDatasets/biomethane-yearRegionTypology.csv",
  header = TRUE,
  sep = ","
)

year_typology_avg <- plotter3(
  biomethane_typology,
  as.integer(biomethane_typology$year),
  biomethane_typology$avgTotalPower,
  biomethane_typology$typology,
  "Typologie",
  "Puissance moyenne fournie en biométhane, par typologie et par année",
  "Année",
  "Puissance totale (GW)"
)

year_typology_sum <- plotter3(
  biomethane_typology,
  as.integer(biomethane_typology$year),
  biomethane_typology$sumTotalPower / 1e3,
  biomethane_typology$typology,
  "Typologie",
  "Puissance totale fournie en biométhane, par typologie et par année",
  "Année",
  "Puissance totale (TWh)"
)

# year_region_typology <- plotter4(
#   biomethane_year_region_typo,
#   biomethane_year_region_typo$region,
#   as.integer(biomethane_year_region_typo$year),
#   biomethane_year_region_typo$avgTotalPower,
#   biomethane_year_region_typo$typology,
#   "Typologie",
#   "Moyenne de la puissance totale fournie en biométhane, par typologie, par région et par année",
#   "Année",
#   "Puissance totale (GWh)"
# )

year_region_avg <- plotter3(
  biomethane_year_region,
  as.integer(biomethane_year_region$year),
  biomethane_year_region$avgTotalPower,
  biomethane_year_region$region,
  "Region",
  "Moyenne de la puissance totale fournie en biométhane, par région et par année",
  "Année",
  "Puissance totale (GWh)"
)

year_region_sum <- plotter3(
  biomethane_year_region,
  as.integer(biomethane_year_region$year),
  biomethane_year_region$sumTotalPower / 1e3,
  biomethane_year_region$region,
  "Region",
  "Somme de la puissance totale fournie en biométhane, par région et par année",
  "Année",
  "Puissance totale (TWh)"
)

print(year_typology_avg)
print(year_typology_sum)
print(year_region_avg)
print(year_region_sum)

save_to_file(year_typology_avg, "biomethaneYearTypologyAvg.png", 1)
save_to_file(year_typology_sum, "biomethaneYearTypologySum.png", 1)
save_to_file(year_region_avg, "biomethaneYearRegionAvg.png", 1)
save_to_file(year_region_sum, "biomethaneYearRegionSum.png", 1)