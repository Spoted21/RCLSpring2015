#    http://www.beardedanalytics.com/todd/iris.csv
# if(!require("downloader")) install.packages("downloader")
# if(!require("httr")) install.packages("httr")
# if(!require("shiny")) install.packages("shiny")
# library(downloader,httr,shiny)
# update.packages(ask=FALSE)

shinyUI(pageWithSidebar(
  headerPanel("Importing Web File"),
  
  sidebarPanel(
  textInput("valuetext", label = h3("CSV URL"), 
            value = ""),
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
               tableOutput("regressionTable"))
    )
  )
))