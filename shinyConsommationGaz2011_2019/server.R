library(shiny)
library(ggplot2)
library(leaflet)

shinyServer(function(input, output) {
  data1119 <- read.csv("../computedDatasets/ConsommationGaz2011_2019.csv", sep = ";")
  data1119$consommation_MWh <- as.numeric(gsub(",", ".", data1119$consommation_MWh))

  output$totalPlot <- renderPlot({
    total1119 <- subset(data1119, annee >= input$anneelim[1] & annee <= input$anneelim[2])
    if (input$varChoice == "Consommation") {
      total1119 <- aggregate(consommation_MWh ~ annee, total1119, sum)
      ggplot(
        total1119,
        aes(x = annee, y = consommation_MWh)
      ) +
        geom_line()
    } else {
      total1119 <- aggregate(pdl ~ annee, total1119, sum)
      ggplot(
        total1119,
        aes(x = annee, y = pdl)
      ) +
        geom_line()
    }
  })

  output$regionPlot <- renderPlot({
    region1119 <- subset(data1119, annee >= input$anneelim[1] & annee <= input$anneelim[2])
    if (input$varChoice == "Consommation") {
      region1119 <- aggregate(consommation_MWh ~ region + annee, region1119, sum)
      ggplot(
        region1119,
        aes(x = annee, y = consommation_MWh, color = region)
      ) +
        geom_line()
    } else {
      region1119 <- aggregate(pdl ~ region + annee, region1119, sum)
      ggplot(
        region1119,
        aes(x = annee, y = pdl, color = region)
      ) +
        geom_line()
    }
  })

  output$departementPlot <- renderPlot({
    departement1119 <- subset(data1119, annee >= input$anneelim[1] & annee <= input$anneelim[2])

    if (input$varChoice == "Consommation") {
      departement1119 <- aggregate(consommation_MWh ~ departement + annee, departement1119, sum)
      ggplot(
        departement1119,
        aes(x = annee, y = consommation_MWh, color = departement)
      ) +
        geom_line() +
        xlab("Année") +
        ylab("Consommation en MWh")
    } else {
      departement1119 <- aggregate(pdl ~ departement + annee, departement1119, sum)
      ggplot(
        departement1119,
        aes(x = annee, y = pdl, color = departement)
      ) +
        geom_line() +
        xlab("Année") +
        ylab("Nombre de points de livraisons")
    }
  })

  output$categoriePlot <- renderPlot({
    categorie1119 <- subset(data1119, annee >= input$anneelim[1] & annee <= input$anneelim[2])

    if (input$varChoice == "Consommation") {
      categorie1119 <- aggregate(consommation_MWh ~ categorie + annee, categorie1119, sum)
      ggplot(
        categorie1119,
        aes(x = annee, y = consommation_MWh, color = categorie)
      ) +
        geom_line() +
        xlab("Année") +
        ylab("Consommation en MWh")
    } else {
      categorie1119 <- aggregate(pdl ~ categorie + annee, categorie1119, sum)
      ggplot(
        categorie1119,
        aes(x = annee, y = pdl, color = categorie)
      ) +
        geom_line() +
        xlab("Année") +
        ylab("Nombre de points de livraisons")
    }
  })

  output$mymap <- renderLeaflet({
    coord1119 <- aggregate(consommation_MWh ~ departement + centroid, data1119, sum)
    coord1119$centroidLng <- as.numeric(gsub("^.*?,", "", coord1119$centroid))
    coord1119$centroidLat <- as.numeric(gsub(",.*", "", coord1119$centroid))
    coord1119 <- coord1119[complete.cases(coord1119), ]
    leaflet("map", data = coord1119, width = "75%", height = "500px") %>%
      addTiles() %>%
      addCircles(
        lng = ~centroidLng, lat = ~centroidLat, stroke = FALSE, fillOpacity = 0.7,
        label = ~ paste(departement, " : ", consommation_MWh, " MWh"), radius = ~ sqrt(consommation_MWh) * 5
      )
  })
})
