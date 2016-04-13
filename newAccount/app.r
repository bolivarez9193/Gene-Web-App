library(shiny)
library(RMySQL)

ui <- fluidPage(
  
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap2.css", align = "center")
  ),
  align = "center",
  
  titlePanel("Create an Account"),
  sidebarLayout(
    sidebarPanel
    (
    align = "left",
    textInput("fname", "*First name:", ""),
    textInput("lname", "*Last name:", ""),
    textInput("comp", "Company/Organization:", ""),
    textInput("email", "*Email:", ""),
    passwordInput("key", "*Password:", ""),
    ("*Required fields."),
    br(),
    br(),
    actionButton("doThis", label = "Submit",
                 style = "color: #fff; background-color: #337ab7; border-color: #2e6da4")
    ),
    
    mainPanel(
      imageOutput("image"),
      ("Copyright 2015"),
  
      textOutput("error"),
      
      tags$head(tags$style("#error{color: red;
                                 font-size: 22px;
                           font-style: italic;
                           }"
                         )
      )
    )
  )
)
server <- function(input, output)
{
  output$image <- renderImage({
    
    return(list(
      src = "www/dna.png",
      contentType = "image/png",
      alt = "dna_helix"))
    
  },deleteFile = FALSE)
  
  observe({
    if(input$doThis==0) return()
    
    isolate({
      if(input$fname != "" && input$lname != "" && input$email != "" && input$key != ""){
        mydb = dbConnect(MySQL(), 
                         user='bjolivarez', 
                         password='insertpassword', 
                         dbname='genomeusers', 
                         host='localhost')
        on.exit(dbDisconnect(mydb))
        checking = sprintf("SELECT * FROM `users` WHERE Email = \"%s\";", input$email)
        rs = dbSendQuery(mydb, checking)
        data = fetch(rs, n = 20)
        dbClearResult(rs)
       
        if(nrow(data) == 0){
          output$error = renderText("")
          if(input$comp == ""){
            sql = sprintf("INSERT INTO `genomeusers`.`users` (`id`, `First Name`, `Last Name`, `Organization`, `Email`, `Key`) VALUES (NULL, '%s', '%s', 'empty', '%s','%s');", 
                          input$fname, input$lname, input$email, input$key)
          }
          else{
            sql = sprintf("INSERT INTO `genomeusers`.`users` (`id`, `First Name`, `Last Name`, `Organization`, `Email`, `Key`) VALUES (NULL, '%s', '%s', '%s', '%s','%s');", 
                          input$fname, input$lname, input$comp, input$email, input$key)
          }
          rs = dbSendQuery(mydb, sql)
          dbClearResult(rs)
        }
        else{
          output$error = renderText("That email is already taken, please try another one.")
        }
       
      }
      else{
        output$error = renderText("Must enter characters in required textboxes.")
      }
    })
  })
  
}


shinyApp(ui=ui, server = server)