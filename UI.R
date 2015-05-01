if(!require("downloader")) install.packages("downloader", dependencies=TRUE)
if(!require("httr")) install.packages("httr", dependencies=TRUE)
if(!require("shiny")) install.packages("shiny", dependencies=TRUE)
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
               h4("Data Summary"),
               wellPanel( 
                 textOutput("DataSummaryText")
               ),
               hr(),
               h4("Select Data"),
               checkboxInput("selectCheck", "Check if you wish to specify columns", value=FALSE),
               
               hr(),
               uiOutput("uiVar") #created on the server side to give options based on data columns
      ),
      
      tabPanel("Change Input File Type",
               
               h5("Here you can provide details about the format of your data:"),
               
               hr(),
               
               checkboxInput('header', 'Check if the first row of your file contains headers', TRUE), 
                 
               radioButtons('sep', 'Separator',
                            c(Comma=',',
                              Semicolon=';',
                              Tab='\t'),
                            ','),
               
               radioButtons('quote', 'Quote',
                            c(None='',
                              'Double Quote'='"',
                              'Single Quote'="'"),
                            '"'),
               
               radioButtons('extension', 'Is the file a csv or txt?',
                            c(CSV='.csv',
                              TXT='.txt'),
                            '.csv')
               
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