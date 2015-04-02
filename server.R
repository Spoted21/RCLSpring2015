
loadpkg <- function(x){
  if(!is.element(x, installed.packages()))
  {install.packages(x)
   library(x,character.only=T)
  }else{library(x,character.only=T)}
}

loadpkg("downloader")
loadpkg("httr")

# setting a generic dataframe to store information globally
inputData <- data.frame()

shinyServer(function(input, output) {
  
  value <- reactive({
    input$action
    isolate(
      if(as.numeric(HEAD(input$valuetext)$headers$"content-length")<5000000 ){
        inputData <<- read.csv(input$valuetext)
        inputData
      } else {
      stop("File is larger than 5MB")
      }
    )
  })
  
  output$summary <- renderTable({
    if(input$action != 0) summary(value())
    else {stop("Please enter a URL")}
  })
  
  output$plot <- renderPlot({
    if(input$action != 0) boxplot(value())
    else {stop("Please enter a URL")}
  })
})

# 
# shinyServer(function(input, output) {
#   output$value2 <- renderPrint({ input$action })
#   # You can access the value of the widget with input$text, e.g.
#   output$value <- renderPrint({ input$text })
#   
# })