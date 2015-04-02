
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



shinyServer(function(input, output) {
  
#   
  output$check <- reactive( {
    input$action
    isolate({
      file  <-  input$valuetext
    
     outputname="myfile.csv"
    
    if( as.numeric(HEAD(file)$headers$"content-length")<5000000){
      
      download(file,destfile="myfile.csv")
      cat(
        paste0("File ",file," has been downloaded to \n",
               getwd(),"/",outputname)
      )
    }else
      stop("File is larger than 5MB")
    
    #Load recently Downloaded File
    mydata <-  read.csv("myfile.csv")
    cat("Data Loaded...\n")
    })#end isolate
    })
  
  
  
  # You can access the value of the widget with input$action, e.g.
  output$value <- renderPrint({
    
    input$action
    
    isolate(
      input$valuetext
    )
    
  })
  
  output$valuetext <- renderPrint({ input$valuetext })
})

# 
# shinyServer(function(input, output) {
#   output$value2 <- renderPrint({ input$action })
#   # You can access the value of the widget with input$text, e.g.
#   output$value <- renderPrint({ input$text })
#   
# })