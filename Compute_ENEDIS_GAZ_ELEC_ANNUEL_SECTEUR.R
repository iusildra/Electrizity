library(rstudioapi)
library(stringr)
path <- getSourceEditorContext()$path
path <- dirname(path)

data <- read.csv(paste(path, "/datasets/conso-elec-gaz-annuelle-par-secteur-dactivite-agregee-commune.csv", sep=""), fileEncoding = "UTF-8", sep=";")

data <- data[, !names(data) %in% c("operateur", "pdla", "nombre_maille_secretisees_a", "indquala", "pdli", "nombre_maille_secretisees_i", 
                                               "indquali", "pdlt", "nombre_maille_secretisees_t", "indqualt", "pdlr", "nombre_maille_secretisees_r", 
                                               "indqualr", "thermor", "partr", "pdlna", "nombre_maille_secretisees_na", "indqualna", "code_commune", "libelle_commune", "code_epci", "libelle_epci", "code_departement", "code_region", "id_filiere", "code_postal")]

names(data)[names(data) == "consoa"] <- "agriculture"
names(data)[names(data) == "consoi"] <- "industrie"
names(data)[names(data) == "consot"] <- "tertiaire"
names(data)[names(data) == "consor"] <- "residentiel"
names(data)[names(data) == "consona"] <- "inconnu"
names(data)[names(data) == "consototale"] <- "totale"
names(data)[names(data) == "libelle_departement"] <- "departement"
names(data)[names(data) == "libelle_region"] <- "region"

dataA <- aggregate(agriculture ~ annee+departement+region+filiere, data, sum)
dataI <- aggregate(industrie ~ annee+departement+region+filiere, data, sum)
dataT <- aggregate(tertiaire ~ annee+departement+region+filiere, data, sum)
dataR <- aggregate(residentiel ~ annee+departement+region+filiere, data, sum)
dataN <- aggregate(inconnu ~ annee+departement+region+filiere, data, sum)
dataTO <- aggregate(totale ~ annee+departement+region+filiere, data, sum)

data12 <- merge(dataA, dataI, by.x=c("annee","departement", "region", "filiere"), by.y=c("annee","departement", "region", "filiere"))
data34 <- merge(dataT, dataR, by.x=c("annee","departement", "region", "filiere"), by.y=c("annee","departement", "region", "filiere"))
data56 <- merge(dataN, dataTO, by.x=c("annee","departement", "region", "filiere"), by.y=c("annee","departement", "region", "filiere"))
data1234 <- merge(data12, data34, by.x=c("annee","departement", "region", "filiere"), by.y=c("annee","departement", "region", "filiere"))
data <- merge(data1234, data56, by.x=c("annee","departement", "region", "filiere"), by.y=c("annee","departement", "region", "filiere"))

popuRegion <- read.csv(paste(path, "/datasets/population_region_2011_2019.csv", sep=""), fileEncoding = "UTF-8", sep=";")
popuDepartement <- read.csv(paste(path, "/datasets/population_departement_2011_2019.csv", sep=""), fileEncoding = "UTF-8", sep=";")

dataEtPopu <- merge(data, popuRegion, by.x=c("annee","region"), by.y=c("annee","region"))
dataEtPopu <- merge(dataEtPopu, popuDepartement, by.x=c("annee","departement"), by.y=c("annee","departement"))
names(dataEtPopu)[names(dataEtPopu) == "habitant.x"] <- "habitant_region"
names(dataEtPopu)[names(dataEtPopu) == "habitant.y"] <- "habitant_departement"

write.csv(dataEtPopu, paste(path, "/computedDatasets/ConsoMWhElecGazENEDIS2011_2021.csv", sep=""), row.names = FALSE)
