library(shiny)
library(leaflet)

shinyUI(fluidPage(


    titlePanel("Consommation de Gaz en France entre 2011 et 2019"),


    sidebarPanel(
      sliderInput("anneelim",
        "Années comprises entre:",
        min = 2011, max = 2019,
        value = c(2011, 2019)),
    ),
    
    mainPanel(
      navbarPage("Représentation",
        navbarMenu("Par ...",
          tabPanel("Total", plotOutput("totalPlot")),
          tabPanel("Région", plotOutput("regionPlot")),
          tabPanel("Département",  plotOutput("departementPlot")),
          tabPanel("Catégorie",  plotOutput("categoriePlot")),
          tabPanel("Carte Département", leafletOutput("departementMap")),
          tabPanel("Carte Région", leafletOutput("regionMap"))
        )
      )
    )
))
