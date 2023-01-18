library(rstudioapi)
path <- getSourceEditorContext()$path
path <- dirname(path)

data1119 <- read.csv(paste(path, "/datasets/consommation-annuelle-de-gaz-par-departement-par-code-naf-2011-a-2019.csv", sep=""), fileEncoding = "UTF-8", sep=";")

data1119 <- data1119[, !names(data1119) %in% c("Filière","geom", "Libellé.catégorie.consommation", "Code.Grand.secteur", "Libellé.Grand.Secteur", "Code.NAF", "Libellé.Secteur.NAF", "Indice.qualité", "Nombre.de.mailles.secretisées", "Code.Département", "Code.Région", "Opérateur")]

names(data1119)[names(data1119) == "Année"] <- "annee"
names(data1119)[names(data1119) == "Code.catégorie.consommation"] <- "categorie"
names(data1119)[names(data1119) == "Consommation..MWh."] <- "consommation_MWh"
names(data1119)[names(data1119) == "Nombre.de.points"] <- "pdl"
names(data1119)[names(data1119) == "Libellé.Département"] <- "departement"
names(data1119)[names(data1119) == "Libellé.Région"] <- "region"
#names(data1119)[names(data1119) == "geom"] <- "coordonnees"

data1119$centroidLng <- gsub("^.*?,","",data1119$centroid)
data1119$centroidLat <- gsub(",.*","",data1119$centroid)
data1119$centroidLng <- gsub(".",",",data1119$centroid)
data1119$centroidLat <- gsub(".",",",data1119$centroid)

popuRegion <- read.csv(paste(path, "/datasets/population_region_2011_2019.csv", sep=""), sep=";")
popuDepartement <- read.csv(paste(path, "/datasets/population_departement_2011_2019.csv", sep=""), sep=";")

dataEtPopu <- merge(data1119, popuRegion, by.x=c("annee","region"), by.y=c("annee","region"))
dataEtPopu <- merge(dataEtPopu, popuDepartement, by.x=c("annee","departement"), by.y=c("annee","departement"))
names(dataEtPopu)[names(dataEtPopu) == "habitant.x"] <- "habitant_region"
names(dataEtPopu)[names(dataEtPopu) == "habitant.y"] <- "habitant_departement"

write.csv2(dataEtPopu, paste(path, "/computedDatasets/ConsommationGaz2011_2019.csv", sep=""), row.names=TRUE)
