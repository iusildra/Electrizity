library(tidyverse)
library(FactoMineR)
library(rstudioapi) 
path <- getSourceEditorContext()$path
path <- dirname(path)

elecMonth <- read.csv(paste(path, "/datasets/bilan-electrique-transpose.csv", sep=""), sep=";")
temperatureMonth <- read.csv(paste(path, "/datasets/temperature-quotidienne-regionale.csv", sep=""), sep=";")

elecMonth <- elecMonth[, !names(elecMonth) %in% c("Catégorie.client")]
elecMonth$Jour <- gsub('.{3}$', '', elecMonth$Jour)
names(elecMonth)[names(elecMonth) == "Jour"] <- "mois"
names(elecMonth)[names(elecMonth) == "Puissance.moyenne.journalière..W."] <- "puissance_moyenne_mois_w"
elecMonth <- aggregate(puissance_moyenne_mois_w ~ mois, elecMonth, sum)

temperatureMonth <- temperatureMonth[, !names(temperatureMonth) %in% c("ID", "Région", "Code.INSEE.région", "TMin...C.", "TMax...C.")]
temperatureMonth$Date <- gsub('.{3}$', '', temperatureMonth$Date)
names(temperatureMonth)[names(temperatureMonth) == "Date"] <- "mois"
names(temperatureMonth)[names(temperatureMonth) == "TMoy...C."] <- "moyenne_celsius"

temperatureMonth <- aggregate(moyenne_celsius ~ mois, temperatureMonth, sum)

transform <- merge(elecMonth, temperatureMonth,  by.x = "mois", by.y = "mois")

write.csv2(transform, paste(path, "/computedDatasets/TemperatureConsoElec_Mois2011_2019.csv", sep=""), row.names=TRUE)
