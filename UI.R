
<<<<<<< HEAD
=======
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


>>>>>>> 453f5235b4025c48f1decca148ff0c5002fa9c8f
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
<<<<<<< HEAD
  textOutput("summary")
=======
  verbatimTextOutput("check")
>>>>>>> 453f5235b4025c48f1decca148ff0c5002fa9c8f
))