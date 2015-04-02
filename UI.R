
loadpkg <- function(x){
  if(!is.element(x, installed.packages()))
  {install.packages(x)
   library(x,character.only=T)
  }else{library(x,character.only=T)}
}


# headers <- HEAD(file)$headers
# filesize <- headers$"content-length"
# filetype <- headers$"content-type"



loadpkg("downloader")
loadpkg("httr")


shinyUI(fluidPage(
  textInput("valuetext", label = h3("URL"), 
            value = ""),
  # Copy the line below to make an action button
  actionButton("action", label = "Get Data"),
  
  hr(),
  #verbatimTextOutput("value"),
  #hr(),
  verbatimTextOutput("valuetext"),
  hr(),
  textOutput("summary")
  verbatimTextOutput("check")
))