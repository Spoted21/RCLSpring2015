

shinyUI(fluidPage(
  textInput("valuetext", label = h3("URL"), 
            value = "Enter URL"),
  # Copy the line below to make an action button
  actionButton("action", label = "Get Data"),
  
  hr(),
  #verbatimTextOutput("value"),
  #hr(),
  verbatimTextOutput("valuetext")
))