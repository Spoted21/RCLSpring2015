
loadpkg <- function(x){
  if(!is.element(x, installed.packages()))
  {install.packages(x)
   library(x,character.only=T)
  }else{library(x,character.only=T)}
}

loadpkg("downloader")
loadpkg("httr")

# setting a generic dataframe to store information globally

shinyServer(function(input, output) {
  
  value <- reactive({
    input$action
    
    isolate(
      if(as.numeric(HEAD(input$valuetext)$headers$"content-length")<5000000 & HEAD(input$valuetext)$headers$"content-type" == "text/csv")
      {
        
        inputData <<- read.csv(input$valuetext)
        inputData
        
      } else if (HEAD(input$valuetext)$headers$"content-type" != "text/csv") 
      {
        
      stop("File does not read as csv")
      
      } else if (as.numeric(HEAD(input$valuetext)$headers$"content-length")>=5000000) 
      {
        
      stop("File is larger than 5MB")
      
      }
    )
  })
  
  output$dataset <- renderDataTable({
    if(input$action != 0) value()
    else {stop("Please enter a URL")}
  })
  
  output$summary <- renderTable({
    if(input$action != 0) summary(value())
    else {stop("Please enter a URL")}
  })
  
  output$plot <- renderPlot({
    if(input$action != 0) boxplot(value())
    else {stop("Please enter a URL")}
  })
  
  output$DataSummaryText <- renderText({
    if(input$action != 0) 
      paste0("Your dataset has " , nrow(value()) ," rows and ",
             length(value()) , " columns. \n You have ", length(complete.cases(value())=="TRUE") ,
             " complete cases which makes for ",round(1- ( length(complete.cases(value())=="TRUE") / nrow(value()) ),2),
             "% missing data.")
    
         
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