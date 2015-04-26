if(!require("downloader")) install.packages("downloader", dependencies=TRUE)
if(!require("httr")) install.packages("httr", dependencies=TRUE)
if(!require("shiny")) install.packages("shiny", dependencies=TRUE)
library(downloader)
library(httr)
library(shiny)

file.size.limit <- 5 #in mb

# setting a generic dataframe to store information globally

shinyServer(function(input, output, session) {
  
  
  
  #creating reactive input types based off whether the user wishes to use online or local filepaths
  output$uiFile <- renderUI({
    
    if(input$locvsurl == "local") { 
      
      fileInput("localFile", "Please choose the CSV file you wish to use", accept = "text/csv")
      
    } else if (input$locvsurl == "url") {
      
      textInput("valuetext", label = "Please enter the URL:", 
                value = "http://www.beardedanalytics.com/todd/iris.csv")
      
    } else {
      
      return()
      
    }
  })
  
  
  
  value <- reactive({
    input$action
    
    isolate(
      
      
      #check if the user is entering a url or a local file
      if (input$locvsurl == "url") {
        
        if('content-length' %in% names(HEAD(input$valuetext)$header) & grepl(input$extension, input$valuetext, fixed=TRUE)){
          
          if(as.numeric(HEAD(input$valuetext)$headers$"content-length")<(file.size.limit*1000000)){
            #inputData only needs to function locally, globally will reference "value()"
              inputData <- read.csv(input$valuetext, header=input$header, sep=input$sep, quote=input$quote) 
            
          } else {
            stop("File is larger than import max limit (", file.size.limit, "mb)")
          }
          
        } else if (!('content-length' %in% names(HEAD(input$valuetext)$header))) {
          stop("File length cannot be determined. Ensure file is csv.")
          
        } else if (!grepl(input$extension, input$valuetext, fixed=TRUE)) {
          stop("Path does not read as declared file type (", input$extension, "). Please double check path or file type options.")
          
        } else {
          stop("Unspecified error in reading file.")
        }
        
        
      #execute if user uses a local file (input named input$localFile)  
      } else if(input$locvsurl == "local") {
        
        userFile <- input$localFile #has "name" (which seems to end in the .csv), size, type (doesn't seem to work), and "datapath" which is where the file is
        
        # check that filepath is a csv
        if(!grepl(input$extension, userFile$name, fixed=TRUE)) 
          stop("Path does not read as declared file type (", input$extension, "). Please double check path or file type options.")
        
        # check that the file size is less than 5 mb (or whatever limit is set at the beginning of this file)
        if(userFile$size > (file.size.limit*1000000)) 
          stop("File is larger than import max limit (", file.size.limit, "mb)")
        
        inputData <- read.csv(userFile$datapath, header=input$header, sep=input$sep, quote=input$quote)        

      #user input for local or url file is not being read correctly...
      } else {
        
        stop("Uh oh...")
        
      }
    )
  })
  
  
  
  
  
  #creating a UI selection menu based off of the input dataset
  output$uiVar <- renderUI({
    if(input$selectData == FALSE | input$action == 0)
      return()
    
    var.names <- names(value())
    
    checkboxGroupInput("selected", "Which variables do you wish to include?", choices=var.names, selected = var.names)
  })
  
  
  
  
  
  output$dataset <- renderDataTable({
    if(input$action == 0) 
      return()
    
    if(input$selectData & !is.null(input$selected)) {
      value()[input$selected] #have to do this as the table will break if it gets a null value for even a second... other tables and plots just flash null then get reloaded... This also protects agains if there is no checkboxes checked...
    } else {
      value()
    }
  })
  
  output$summary <- renderTable({
    if(input$action == 0) 
      return()
    
    if(input$selectData & !is.null(input$selected)) {
      summary(value()[input$selected])
    } else {
      summary(value())
    }
  })
  
  output$plot <- renderPlot({
    if(input$action == 0) 
      return()
    
    if(input$selectData & !is.null(input$selected)) {
      boxplot(value()[input$selected],las=1,col=c("orange","lightgreen","lightblue"))
    } else {
      boxplot(value(),las=1,col=c("orange","lightgreen","lightblue"))
    }
  })
  
  output$ScatPlot <- renderPlot({
    if(input$action == 0) 
      return()
    
    if(input$selectData & !is.null(input$selected)) {
      plot(value()[input$selected])
    } else {
      plot(value())
    }
  })
  
  
  output$DataSummaryText <- renderText({
    if(input$action != 0) 
      paste0("Your dataset has " , nrow(value()) ," rows and ",
             length(value()) , " columns. \n You have ", length(complete.cases(value())=="TRUE") ,
             " complete cases which makes for ",round(1- ( length(complete.cases(value())=="TRUE") / nrow(value()) ),2),
             "% missing data.")
  })
  
  
  
  
  
  output$uiDV <- renderUI({
    if(input$action == 0)
      return()
    
    if(input$selectData & !is.null(input$selected)){
      selectInput("dv", "Please select the dependent variable", choices=input$selected)
    } else {
      selectInput("dv", "Please select the dependent variable", choices=names(value()))
    }
  })
  
  
  
  
  
  regressionModel <- reactive({
    if(input$action == 0)
      return()
    
    # the following condition prevents an initial error when loading regression tab (due to not reading in the dv yet), but 
    if(!is.null(input$dv)){ 
      if(input$selectData & !is.null(input$selected)){
        if(length(input$selected)<2)
          stop("2 or more variables are needed for regression")
        
        if(length(input$selected)==2){
          dvColNum <- which(input$selected == input$dv)
          ivColNum <- which(input$selected != input$dv)
          
          lm(
            as.formula(
              paste0(input$selected[dvColNum],
                "~",
                input$selected[ivColNum]
              )
            ),
            data=value()[input$selected]
          )
        } else {
          dvColNum <- which(input$selected == input$dv)
          
          lm(value()[input$selected][,dvColNum] ~ ., 
             data = value()[input$selected][,-dvColNum])
        }
      } else {
        dvColNum <- which(names(value()) == input$dv)
        
        lm(value()[,dvColNum] ~ ., 
           data=value()[,-dvColNum])
      }
    }
    
  })
  
  
  output$regressionTable <- renderTable({
    if(input$action == 0)
      return()
    
    regressionModel()
  })
  
  output$adjRSq <- renderText({
    if(input$action == 0)
      return()
    
    #use "getElement", as $ throws the error "$ invalid for atomic vectors"
    getElement(summary(regressionModel()), "adj.r.squared")
  })
  
})


# 
# shinyServer(function(input, output) {
#   output$value2 <- renderPrint({ input$action })
#   # You can access the value of the widget with input$text, e.g.
#   output$value <- renderPrint({ input$text })
#   
# })