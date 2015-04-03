
loadpkg <- function(x){
  if(!is.element(x, installed.packages()))
  {install.packages(x)
   library(x,character.only=T)
  }else{library(x,character.only=T)}
}

loadpkg("downloader")
loadpkg("httr")
file.size.limit <- 5 #in mb

# setting a generic dataframe to store information globally

shinyServer(function(input, output) {
  
  value <- reactive({
    input$action
    
    isolate(
      if('content-length' %in% names(HEAD(input$valuetext)$header) & HEAD(input$valuetext)$headers$"content-type" == "text/csv"){
        
        if(as.numeric(HEAD(input$valuetext)$headers$"content-length")<(file.size.limit*1000000)){
          inputData <<- read.csv(input$valuetext)
          inputData
        } else {
          stop("File is larger than import max limit (", file.size.limit, "mb)")
        }
      
      } else if (!('content-length' %in% names(HEAD(input$valuetext)$header))) {
        stop("File length cannot be determined. Ensure file is csv.")
      
      } else if (HEAD(input$valuetext)$headers$"content-type" != "text/csv") {
      stop("Path does not read as csv, please double check path.")
      
      } else {
        stop("Unspecified error in reading file.")
      }
      
    )
  })
  
  output$dataset <- renderDataTable({
    if(input$action != 0) value()
  })
  
  output$summary <- renderTable({
    if(input$action != 0) summary(value())
  })
  
  output$plot <- renderPlot({
    if(input$action != 0) boxplot(value())
  })
  
  output$DataSummaryText <- renderText({
    if(input$action != 0) 
      paste0("Your dataset has " , nrow(value()) ," rows and ",
             length(value()) , " columns. \n You have ", length(complete.cases(value())=="TRUE") ,
             " complete cases which makes for ",round(1- ( length(complete.cases(value())=="TRUE") / nrow(value()) ),2),
             "% missing data.")
  })

})

# 
# shinyServer(function(input, output) {
#   output$value2 <- renderPrint({ input$action })
#   # You can access the value of the widget with input$text, e.g.
#   output$value <- renderPrint({ input$text })
#   
# })