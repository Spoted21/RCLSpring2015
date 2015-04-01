

shinyServer(function(input, output) {
  
  # You can access the value of the widget with input$action, e.g.
  output$value <- renderPrint({ input$action })
  output$valuetext <- renderPrint({ input$valuetext })
})

# 
# shinyServer(function(input, output) {
#   output$value2 <- renderPrint({ input$action })
#   # You can access the value of the widget with input$text, e.g.
#   output$value <- renderPrint({ input$text })
#   
# })
