library(rstudioapi) 
path <- getSourceEditorContext()$path
path <- dirname(path)

data1119 <- read.csv(paste(path, "/datasets/consommation-annuelle-de-gaz-par-departement-par-code-naf-2011-a-2019.csv", sep=""), sep=";")

data1119 <- data1119[, !names(data1119) %in% c("Filière", "Libellé.catégorie.consommation", "Code.Grand.secteur", "Libellé.Grand.Secteur", "Code.NAF", "Libellé.Secteur.NAF", "Indice.qualité", "Nombre.de.mailles.secretisées", "Code.Département", "Code.Région", "Opérateur")]

names(data1119)[names(data1119) == "Année"] <- "annee"
names(data1119)[names(data1119) == "Code.catégorie.consommation"] <- "categorie"
names(data1119)[names(data1119) == "Consommation..MWh."] <- "consommation_MWh"
names(data1119)[names(data1119) == "Nombre.de.points"] <- "pdl"
names(data1119)[names(data1119) == "Libellé.Département"] <- "departement"
names(data1119)[names(data1119) == "Libellé.Région"] <- "region"
names(data1119)[names(data1119) == "geom"] <- "coordonnees"

write.csv2(data1119, paste(path, "/computedDatasets/ConsommationGaz2011_2019.csv", sep=""), row.names=TRUE)