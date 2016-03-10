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
  
  
  
  
  
  #this evaluates only when the action button ("Get Data" from user perspective) is pressed.
  #  this variable (fullData()) the data that will be used through the rest of the application
  fullData <- reactive({
    input$action
    
    #code inside isolate does not trigger the "reactive" to re-evaluate
    isolate(
      
      #check if the user is entering a url or a local file
      #  execute this chunk if user is attempting to use a URL
      if (input$locvsurl == "url") {
        
        #see if URL reports file length. If not, do not import.
        if (!('content-length' %in% names(HEAD(input$valuetext)$header)))
          stop("File length cannot be determined (check that file exists).\nUnable to determine length is less than max limit (", file.size.limit, "mb).\nAborting import.")
        
        #see if the extension declared is included in the filepath
        if (!grepl(input$extension, input$valuetext, fixed=TRUE))
          stop("Path does not read as declared file type (", input$extension, "). Please double check path or file type options.")
        
        #checking that reported length is within parameter (set above)
        if(as.numeric(HEAD(input$valuetext)$headers$"content-length")>(file.size.limit*1000000))
          stop("File is larger than import max limit (", file.size.limit, "mb)")
        
        #passed all considered error checks, so try to read in the data
        trialRead <- try(inputData <- read.csv(input$valuetext, header=input$header, sep=input$sep, quote=input$quote), 
                         silent=TRUE)
        
        #check if the "try()" failed. If so, an unconsidered error occured
        if(class(trialRead) == "try-error")
          stop("Unspecified Error")
        
        #if there was no failure, output the value of "trialRead" (should be "inputData")
        trialRead
      
      #  execute this chunk if user is attempting to use a local file (named input$localFile)  
      } else if(input$locvsurl == "local") {
        
        userFile <- input$localFile #has elements of "name" (which seems to end in the .csv), size, type (doesn't seem to work), and "datapath" which is where the file is
        
        # check that filepath is a csv
        if(!grepl(input$extension, userFile$name, fixed=TRUE)) 
          stop("Path does not read as declared file type (", input$extension, "). Please double check path or file type options.")
        
        # check that the file size is less than 5 mb (or whatever limit is set at the beginning of this file)
        if(userFile$size > (file.size.limit*1000000)) 
          stop("File is larger than import max limit (", file.size.limit, "mb)")
         
        #passed all considered error checks, so try to read in the data
        trialRead <- try(inputData <- read.csv(userFile$datapath, header=input$header, sep=input$sep, quote=input$quote), 
                         silent=TRUE)
        
        #check if the "try()" failed. If so, an unconsidered error occured
        if(class(trialRead) == "try-error")
          stop("Unspecified Error")
        
        #if there was no failure, output the value of "trialRead" (should be "inputData")
        trialRead

      #user input for local or url file is not being read correctly...
      } else {
        stop("Uh oh...")
        
      }
    )
  })
  
  
  
  
  
  #creating a UI selection menu based off of the input dataset
  output$uiVar <- renderUI({
    
    #if "selectCheck" hasn't been selected OR users haven't read in data, don't execute
    if(input$selectCheck == FALSE | input$action == 0)
      return()
    
    #make a checkbox group with the columns as options
    checkboxGroupInput("selected", "Which variables do you wish to include?", choices=names(fullData()), selected = names(fullData()))
    
  })
  
  
  
  
  
  #create dataset (based on overall dataset) that includes all variables (if selected isn't checked),
  #  or just the variables the user has selected (if it is checked)
  selectedData <- reactive({
    #don't bother if the user hasn't input a dataset
    if(input$action == 0) 
      return()
    
    #makes sure that the user has at least 2 variable selected (if they've elected to select variables)
    if(input$selectCheck & is.null(input$selected))
      stop("At least 1 variable must be selected")
    
    #if users select columns, use only selected columns; otherwise, use full dataset. Done this way (instead of just writing "fullData()") to match other outputs
    if(input$selectCheck & !is.null(input$selected)) {
      fullData()[input$selected]
      
    } else {
      fullData()
      
    }
  })
  
  
  
  
  
  #creating the data summary text (to be shown under file selection)
  output$DataSummaryText <- renderText({
    
    #don't bother if the user hasn't input a dataset
    if(input$action == 0) 
      return()
    
    #need the error to prevent text from generating when no variables are selected
    if(input$selectCheck & is.null(input$selected))
      stop("At least 1 variable must be selected")
    
    #need the if/else as the words are different depending on which is used. First chunk for when user has selected data
    if(input$selectCheck & !is.null(input$selected)) {
    paste0("Your selected dataset has " , nrow(selectedData()) ," rows and ",
           length(selectedData()) , " columns. \n You have ", length(complete.cases(selectedData())=="TRUE") ,
           " complete cases which makes for ", round(1- ( length(complete.cases(selectedData())=="TRUE") / nrow(selectedData()) ),2),
           "% missing data.")
    
    } else {
      paste0("Your dataset has " , nrow(fullData()) ," rows and ",
             length(fullData()) , " columns. \n You have ", length(complete.cases(fullData())=="TRUE") ,
             " complete cases which makes for ", round(1- ( length(complete.cases(fullData())=="TRUE") / nrow(fullData()) ),2),
             "% missing data.")
      
    }
  })
  
  
  
  
  
  #generating the dataset to be displayed
  output$dataset <- renderDataTable({
    
    #don't bother if the user hasn't input a dataset
    if(input$action == 0) 
      return()
    
    #output the dataset "selectedData()"
    selectedData()
    
  })
  
  
  
  
  
  #creating the summary statistics to be displayed
  output$summary <- renderTable({
    
    #don't bother if the user hasn't input a dataset
    if(input$action == 0) 
      return()
    
    #summarize the data
    summary(selectedData())
    
  })
  
  
  
  
  
  #creating the boxplot to be displayed  
  output$plot <- renderPlot({
    
    #don't bother if the user hasn't input a dataset
    if(input$action == 0) 
      return()
    
    #create a boxplot of the data. las turns the names, col gives colors (that repeat as needed)
    boxplot(selectedData(),las=1,col=c("wheat", "orange","lightgreen","lightblue","thistle"))
      
  })
  
  
  
  
  
  #creating the scatterplot to be displayed
  output$ScatPlot <- renderPlot({
    
    #don't bother if the user hasn't input a dataset
    if(input$action == 0) 
      return()
    
    #plot the data
    plot(selectedData(),las=1)
    
  })
  
  
  
  
  
  #allowing user to select the DV (for multiple regression) from the list of variables
  output$uiDV <- renderUI({
    
    #don't bother if the user hasn't input a dataset
    if(input$action == 0)
      return()
    
    #allow users to select choices from the column names of the data
    selectInput("dv", "Please select the dependent variable", choices=names(selectedData()))
    
  })
  
  
  
  
  
  #generates a regression model based on the selected DV and included IVs
  regressionModel <- reactive({
    
    #don't run if the DV hasn't been loaded yet
    if(is.null(input$dv))
      return()
            
    #throws error if user selects less than 2 variables
    if(ncol(selectedData())<2)
      stop("2 or more variables are needed for regression")
    
    #executes a special proceedure if user only selects 2 variables
    if(ncol(selectedData())==2){
      dvColNum <- which(names(selectedData()) == input$dv)
      ivColNum <- which(names(selectedData()) != input$dv)
      
      #use this formula so that names still display to user in the regression output
      lm(
        as.formula(
          paste0(input$selected[dvColNum],
                 "~",
                 input$selected[ivColNum])
        ),
        data=selectedData()
      )
      
    #following chunk executes if 3 vars or more
    } else {
      dvColNum <- which(names(selectedData()) == input$dv)
      
      lm(selectedData()[,dvColNum] ~ ., 
         data = selectedData()[,-dvColNum])
      
    }
  })
  
  
  
  
  
  #creating the output for multiple regression
  output$regressionTable <- renderTable({
    
    #don't bother if the user hasn't input a dataset
    if(input$action == 0)
      return()
    
    #display the regression model
    regressionModel()
    
  })
  
  
  
  
  
  #providing the user with the adjusted R^2 from the model
  output$adjRSq <- renderText({
    
    #don't bother if the user hasn't input a dataset
    if(input$action == 0)
      return()
    
    #if the model isn't formed, don't ask for the adjusted R^2
    if(is.null(regressionModel()))
      return()
    
    #grab the adjusted R^2 of the model
    getElement(summary(regressionModel()), "adj.r.squared") #use "getElement", as $ throws the error "$ invalid for atomic vectors"
    
  })
})
