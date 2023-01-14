library(shiny)
library(ggplot2)
library(leaflet)

shinyServer(function(input, output) {
    
  data1119 <- read.csv("../computedDatasets/ConsommationGaz2011_2019.csv", sep=";")
  data1119$consommation_MWh <- as.numeric(gsub(",", ".", data1119$consommation_MWh))
  
  output$totalPlot <- renderPlot({
    total1119 <- subset(data1119, annee >= input$anneelim[1] & annee <= input$anneelim[2])
    #if(input$varChoice == "Consommation") {
    total1119 <- aggregate(consommation_MWh ~ annee, total1119, sum)
    ggplot(total1119, 
           aes(x=annee, y=consommation_MWh)) +
      geom_line()
    #}
    #else {
    #  total1119 <- aggregate(pdl ~ annee, total1119, sum)
    #  ggplot(total1119, 
    #         aes(x=annee, y=pdl)) +
    #    geom_line()
    #}
  })
  
  output$regionPlot <- renderPlot({
    region1119 <- subset(data1119, annee >= input$anneelim[1] & annee <= input$anneelim[2])
    if(input$varChoice == "Consommation") {
      region1119 <- aggregate(consommation_MWh ~ region+annee, region1119, sum)
      ggplot(region1119, 
             aes(x=annee, y=consommation_MWh, color=region)) +
        geom_line()
    }
    else {
      region1119 <- aggregate(pdl ~ region+annee, region1119, sum)
      ggplot(region1119, 
             aes(x=annee, y=pdl, color=region)) +
        geom_line()
    }
  })
  
  output$departementPlot <- renderPlot({
    departement1119 <- subset(data1119, annee >= input$anneelim[1] & annee <= input$anneelim[2])
    
    departement1119 <- aggregate(consommation_MWh ~ departement+annee, departement1119, sum)
    ggplot(departement1119, 
           aes(x=annee, y=consommation_MWh, color=departement)) +
      geom_line() +
      xlab("Année")+
      ylab("Consommation en MWh")
    
  })
  
  output$categoriePlot <- renderPlot({
    categorie1119 <- subset(data1119, annee >= input$anneelim[1] & annee <= input$anneelim[2])

    categorie1119 <- aggregate(consommation_MWh ~ categorie+annee, categorie1119, sum)
    ggplot(categorie1119, 
           aes(x=annee, y=consommation_MWh, color=categorie)) +
      geom_line() +
      xlab("Année")+
      ylab("Consommation en MWh")

    
  })

  output$departementMap <- renderLeaflet({
    data1119 <- subset(data1119, annee >= input$anneelim[1] & annee <= input$anneelim[2])

    coord1119 <- aggregate(consommation_MWh ~ departement+centroid+habitant_departement, data1119, sum)
    coord1119$centroidLng <- as.numeric(gsub("^.*?,","",coord1119$centroid))
    coord1119$centroidLat <- as.numeric(gsub(",.*","",coord1119$centroid))
    coord1119 <- coord1119[complete.cases(coord1119), ]
    
    leaflet(coord1119) %>% 
      addTiles() %>% 
      addCircles(lng=~centroidLng, lat=~centroidLat, stroke = FALSE, fillOpacity= 0.7,
                 label = ~paste(departement, " : ", format(round(consommation_MWh/habitant_departement, 3), nsmall = 3), " MWh/habitant"), radius = ~((consommation_MWh/habitant_departement)*5000))
    
                 #label = ~paste(departement, " : ", consommation_MWh, " MWh"), radius = ~sqrt(consommation_MWh)*5)
  })
  output$regionMap <- renderLeaflet({
    data1119 <- subset(data1119, annee >= input$anneelim[1] & annee <= input$anneelim[2])
    
    region1119<- aggregate(consommation_MWh ~ region+habitant_region, data1119, sum)
    
    data1119$centroidLng <- as.numeric(gsub("^.*?,","",data1119$centroid))
    data1119$centroidLat <- as.numeric(gsub(",.*","",data1119$centroid))
    centroidLng <- aggregate(centroidLng ~ region, data1119, mean)
    centroidLat <- aggregate(centroidLat ~ region, data1119, mean)
    
    region1119 <- merge(region1119, centroidLng, by= "region")
    region1119 <- merge(region1119, centroidLat, by= "region")
    
    leaflet(region1119) %>% 
      addTiles() %>% 
      addCircles(lng=~centroidLng, lat=~centroidLat, stroke = FALSE, fillOpacity= 0.7,
                 label = ~paste(region, " : ", format(round(consommation_MWh/habitant_region, 3), nsmall = 3), " MWh/habitant"), radius = ~((consommation_MWh/habitant_region)*12000))
    
  })
})
