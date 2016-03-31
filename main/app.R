library(shiny)
library(seqinr)
library(markdown)
library(Rcpp)
sourceCpp('fun.cpp')


options(shiny.maxRequestSize = 150*1024^2)

ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap2.css", align = "center")),
  
  tags$head(
    tags$style(HTML("
                    body{
                    background-color: #444444;
                    }
                    "))),
  
  align = "left",
  absolutePanel(left = "0%", width = "100%", 
                wellPanel(titlePanel("Zoosh"))),
  
  absolutePanel(left = "0%", top = "8%", width = "100%",
  navbarPage("",
             tabPanel("Home",
                          
                      sidebarPanel(width = 2,
                          fileInput('dataFile', 'Import data:',
                                    accept=c('fasta','.fasta')),
                          selectInput("var",
                                      label = "Choose  a genome:",
                                      choices = list("Fragaria vesca", "Fragaria ananassa"),
                                      selected = "Fragaria vesca")),
                      mainPanel(
                        textOutput("text1")),
                        imageOutput("image")
                      ),
             tabPanel("Data Visualization",
                      "Visualize your data! Coming soon tho..."),
             tabPanel("Online Databases",
                     # absolutePanel(left = "40%",
                      
                     fluidRow(
                       sidebarPanel(
                      imageOutput("ncbi"),
                      tags$a(href="http://www.ncbi.nlm.nih.gov/genome/", "NCBI"),
                      tags$hr()
                      
                      )
                       
                      )),
             tabPanel("About", 
                      "This is a genometric mutation analysis application. Simply upload a Fasta document
                      contining the genetic data of a species and wait to view the results in which a mutation occured")
             )
    )
  )
# mainPanel(
#   tableOutput('Stuff')
#   
# )

server <- function(input, output, session)
{
  output$ncbi <- renderImage({
    
    return(list(
      src = "www/NCBI.jpg",
      contentType = "image/jpg",
      width = 300,
      height = 100,
      alt = "NCBI"))
    
  },deleteFile = FALSE)
  
  output$text1 <- renderText({
    args <- switch(input$var,
                   "Fragaria vesca" = "This is Fragaria vesca, the wild strawberry",
                   "Fragaria ananassa" = "This is Fragaria ananassa, the market strawberry")
  })
  
  output$image <- renderImage({
    args2 <- switch(input$var,
                    "Fragaria vesca" =list(
                      src = "www/Fragaria_vesca.jpg",
                      contentType = "image/jpg",
                      width = 300,
                      height = 300,
                      alt = "Fragaria_vesca"
                     ),
                    "Fragaria ananassa" = list(
                      src = "www/Fragaria_ananassa.jpg",
                      contentType = "image/jpg",
                      width = 300,
                      height = 300,
                      alt = "Fragaria_ananassa"
                     )
    )
  }, deleteFile = FALSE)
  
  readingFile(3)
  
  output$contents <- renderTable({
    inFile <- input$dataFile
    
    if (is.null(inFile))
      return(NULL)
    
    read.fasta(file = inFile)
  
  })
  
}
shinyApp(ui, server = server)