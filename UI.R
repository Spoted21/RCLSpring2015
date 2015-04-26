#    http://www.beardedanalytics.com/todd/iris.csv
if(!require("downloader")) install.packages("downloader")
if(!require("httr")) install.packages("httr")
if(!require("shiny")) install.packages("shiny")
library(downloader)
library(httr)
library(shiny)


shinyUI(pageWithSidebar(
  headerPanel("CSV Exploratory Tool"),
  
  sidebarPanel(
    
    tabsetPanel(
      
      tabPanel("Start",
                
        selectInput("locvsurl", "Select whether you'd prefer to use a local file or one from the web:",
                    choices = list("Local File" = "local",
                                   "URL" = "url"), selected="url"),
        
        textOutput("defaultText"),
        
        uiOutput("uiFile"),
        # Copy the line below to make an action button
        actionButton("action", label = "Get Data"),
        hr(),
        hr(),
        h4("Data Summary"),
        wellPanel( 
          textOutput("DataSummaryText")
        ),
        hr(),
        h4("Select Data"),
        checkboxInput("selectData", "Check if you wish to specify columns", value=FALSE),
        
        hr(),
        uiOutput("uiVar") #created on the server side to give options based on data columns
      ),
    
      tabPanel("Data Types",
                  
        h5("If your file isn't a CSV, please give us some information to help us read it in")
        
        
      
      )
    )
  ),
  #
  mainPanel(
    
    #something
    
    tabsetPanel(
      tabPanel("The Data", dataTableOutput("dataset")),
      tabPanel("Summary Statistics", tableOutput("summary")),
      tabPanel("Box Plots", plotOutput("plot")),
      tabPanel("Regression", 
               uiOutput("uiDV"),
               hr(),
               h4("Variance Explained (Adjusted R Squared):"),
               textOutput("adjRSq"),
               hr(),
               h4("Summary Table:"),
               tableOutput("regressionTable")),
      tabPanel("Scatter Plots",plotOutput("ScatPlot"))
    )
  )
))