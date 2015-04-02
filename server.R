library(downloader)
library(httr)

# setting a generic dataframe to store information globally
inputData <- data.frame()
  
shinyServer(function(input, output) {
  
  # You can access the value of the widget with input$action, e.g.
  value <- reactive({
    
    input$action
    
    isolate(
      
      if(as.numeric(HEAD(input$valuetext)$headers$"content-length")<5000000 ){
        inputData <<- read.csv(input$valuetext)
      } else {
      stop("File is larger than 5MB")
      }
      
    )
    
  })
  
  output$valuetext <- renderPrint({ input$valuetext })
  
  output$summary <- reactive({summary(iris)})
})

# 
# shinyServer(function(input, output) {
#   output$value2 <- renderPrint({ input$action })
#   # You can access the value of the widget with input$text, e.g.
#   output$value <- renderPrint({ input$text })
#   
# })