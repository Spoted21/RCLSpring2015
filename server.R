if(!require("downloader")) install.packages("downloader", dependencies=TRUE)
if(!require("httr")) install.packages("httr", dependencies=TRUE)
if(!require("shiny")) install.packages("shiny", dependencies=TRUE)
library(downloader)
library(httr)
library(shiny)

# This variable is intended to set the file size limit in mB (it will be called on later)
file.size.limit <- 5 #in mb


shinyServer(function(input, output, session) {
  
  #creating reactive input types based off whether the user wishes to use online or local filepaths
  output$uiFile <- renderUI({
    
    #check the input "locvsurl" to see which option the user selected
    if(input$locvsurl == "local") { 
      fileInput("localFile", "Please choose the CSV file you wish to use", accept = "text/csv")
      
    } else if (input$locvsurl == "url") {
      textInput("valuetext", label = "Please enter the URL:", 
                value = "http://www.beardedanalytics.com/todd/iris.csv")
      
    } else {
      return()
    }
  })
  
  
  
  
  
  #this evaluates only when the action button ("Get Data" from user perspective) is pressed
  value <- reactive({
    input$action
    
    #code inside isolate does not trigger the "reactive" to re-evaluate
    isolate(
      
      #check if the user is entering a url or a local file
      #  execute this chunk if user is attempting to use a URL
      if (input$locvsurl == "url") {
        
        # see if code passes error checks of length (making sure it can be read from the input) and extension (set by user, default is .csv).
        if('content-length' %in% names(HEAD(input$valuetext)$header) & grepl(input$extension, input$valuetext, fixed=TRUE)){
          
          #checking that reported length is within parameter (set above)
          if(as.numeric(HEAD(input$valuetext)$headers$"content-length")>(file.size.limit*1000000))
            stop("File is larger than import max limit (", file.size.limit, "mb)")
          
          #if file length checks out, this evaluates
          #inputData only needs to function locally, globally will reference "value()"
          inputData <- read.csv(input$valuetext, header=input$header, sep=input$sep, quote=input$quote) 
            
        #didn't pass error checks (file length reported and extension match), so check which went wrong and return a specified error
        } else if (!('content-length' %in% names(HEAD(input$valuetext)$header))) {
          stop("File length cannot be determined (check that file exists).\nUnable to determine length is less than max limit (", file.size.limit, "mb).\nAborting import.")
          
        } else if (!grepl(input$extension, input$valuetext, fixed=TRUE)) {
          stop("Path does not read as declared file type (", input$extension, "). Please double check path or file type options.")
          
        #neither predicted error went wrong, so return that there was an unspecified error
        } else {
          stop("Unspecified error in reading file.")
        }
        
        
        
      #  execute this chunk if user is attempting to use a local file (named input$localFile)  
      } else if(input$locvsurl == "local") {
        
        userFile <- input$localFile #has elements of "name" (which seems to end in the .csv), size, type (doesn't seem to work), and "datapath" which is where the file is
        
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
    #if "selectData" hasn't been selected OR users haven't read in data, don't execute
    if(input$selectData == FALSE | input$action == 0)
      return()
    
    checkboxGroupInput("selected", "Which variables do you wish to include?", choices=names(value()), selected = names(value()))
  })
  
  
  
  
  
  #creating the data summary text (to be shown under file selection)
  output$DataSummaryText <- renderText({
    if(input$action != 0) 
      paste0("Your dataset has " , nrow(value()) ," rows and ",
             length(value()) , " columns. \n You have ", length(complete.cases(value())=="TRUE") ,
             " complete cases which makes for ",round(1- ( length(complete.cases(value())=="TRUE") / nrow(value()) ),2),
             "% missing data.")
  })
  
  
  
  
  
  #generating the dataset to be displayed
  output$dataset <- renderDataTable({
    #don't bother if the user hasn't input a dataset
    if(input$action == 0) 
      return()
    
    if(input$selectData & !is.null(input$selected)) {
      value()[input$selected] #have to do this as the table will break if it gets a null value for even a second... other tables and plots just flash null then get reloaded... This also protects agains if there is no checkboxes checked...
    } else {
      value()
    }
  })
  
  
  
  
  
  #creating the summary statistics to be displayed
  output$summary <- renderTable({
    #don't bother if the user hasn't input a dataset
    if(input$action == 0) 
      return()
    
    if(input$selectData & !is.null(input$selected)) {
      summary(value()[input$selected])
    } else {
      summary(value())
    }
  })
  
  
  
  
  
  #creating the boxplot to be displayed  
  output$plot <- renderPlot({
    #don't bother if the user hasn't input a dataset
    if(input$action == 0) 
      return()
    
    if(input$selectData & !is.null(input$selected)) {
      boxplot(value()[input$selected],las=1,col=c("orange","lightgreen","lightblue"))
    } else {
      boxplot(value(),las=1,col=c("orange","lightgreen","lightblue"))
    }
  })
  
  
  
  
  
  #creating the scatterplot to be displayed
  output$ScatPlot <- renderPlot({
    #don't bother if the user hasn't input a dataset
    if(input$action == 0) 
      return()
    
    if(input$selectData & !is.null(input$selected)) {
      plot(value()[input$selected])
    } else {
      plot(value())
    }
  })
  
  
  
  
  
  #allowing user to select the DV (for multiple regression) from the list of variables
  output$uiDV <- renderUI({
    #don't bother if the user hasn't input a dataset
    if(input$action == 0)
      return()
    
    if(input$selectData & !is.null(input$selected)){
      selectInput("dv", "Please select the dependent variable", choices=input$selected)
    } else {
      selectInput("dv", "Please select the dependent variable", choices=names(value()))
    }
  })
  
  
  
  
  
  #generates a regression model based on the selected DV and included IVs
  regressionModel <- reactive({
    #don't bother if the user hasn't input a dataset
    if(input$action == 0)
      return()
    
    #ensures the DV is read in before the regression model is made
    if(!exists("input$dv")){
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
    }
    
  })
  
  
  output$regressionTable <- renderTable({
    #don't bother if the user hasn't input a dataset
    if(input$action == 0)
      return()
    
    regressionModel()
  })
  
  output$adjRSq <- renderText({
    #don't bother if the user hasn't input a dataset
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