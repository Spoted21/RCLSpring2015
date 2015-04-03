
loadpkg <- function(x){
  if(!is.element(x, installed.packages()))
  {install.packages(x)
   library(x,character.only=T)
  }else{library(x,character.only=T)}
}

loadpkg("downloader")
loadpkg("httr")


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
  uiOutput("ui") #created on the server side to give options based on data columns
 ),
  #
  mainPanel(
    
    #something
    
    tabsetPanel(
      tabPanel("The Data", dataTableOutput("dataset")),
      tabPanel("Summary Statistics", tableOutput("summary")),
      tabPanel("Box Plots", plotOutput("plot"))
    )
  )
))