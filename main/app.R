library(shiny)
library(seqinr)
library(markdown)
library(Rcpp)
sourceCpp('fun.cpp')

ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap2.css", align = "center")),
  
  tags$head(
    tags$style(HTML("body{background-color: #444444;}"))),
  
  align = "left",
  absolutePanel(left = "0%", width = "100%", 
                wellPanel(titlePanel("Zoosh"))),
  
  absolutePanel(left = "0%", top = "8%", width = "100%",
  navbarPage("",
             tabPanel("Home",
                      tags$h2("Analyze"),
                      sidebarPanel(width = 2,
                                   
                                   #Drop down menu
                                   selectInput("organism", "Organism:", 
                                               choices = c("Fragaria_vesca", "Fragaria_ananassa")),
                                   #Drop down menu
                                   selectInput("task", "Determine:", 
                                               choices = c("Mutations", "Amino acids")),
                                   #Data file input
                                   fileInput('dataFile', 'Import data:',
                                    accept=c('fasta','.fasta'))
                          ),
                      absolutePanel(width = "23%", right = "40%",
                                    wellPanel(imageOutput("image"))),
                      
                      absolutePanel(width = "34%", right = "7%",
                                    align = "right",
                                    wellPanel(tags$h2(textOutput("name"))))
                      ),
             
             tabPanel("Data Visualization", tableOutput('contents')
                      #readFile(data) 
                      #plotOutput("gl")
                      
                      ),
             
             tabPanel("Online Databases",
                      tags$img(src = "NCBI.jpg", width = "300px", height = "100px"),
                      tags$a(href="http://www.ncbi.nlm.nih.gov/genome/browse/", " NCBI", target = "_blank"),
                      tags$hr(),
                      tags$img(src = "phyto.jpg", width = "300px", height = "100px"),
                      tags$a(href="https://phytozome.jgi.doe.gov/pz/portal.html", "Phytozome", target = "_blank"),
                      tags$hr(),
                      tags$img(src = "wsu.jpg", width = "300px", height = "100px"),
                      tags$a(href="ftp://ftp.bioinfo.wsu.edu/species/", "Washinton State University", target = "_blank")
    
                     ),
             tabPanel("About", 
                      "This is a genome analysis application, created by a group of students at the University of Texas - Rio Grande Valley. Simply upload a Fasta document
                      contining the genetic data of a species and wait to view the results in which a mutation occured")
             )
    )
  )

options(shiny.maxRequestSize = 220*1024^2)
#options(rgl.useNULL=TRUE)
server <- function(input, output, session)
{
  
  # Display the data file 
  output$contents <- renderTable({
    inFile <- input$dataFile
    if (is.null(inFile))
      return(NULL)
    data <- read.csv(inFile$datapath, header = TRUE, sep = c(Tab='\t'))
    #readFile(data)
  })
  
#   output$gl <- renderWebGL({
#     points3d(1:20, 20:25, 1:10)
#     axes3d()
#  })
  
  organismInput <- reactive({
    switch(input$organism,
           "Fragaria_vesca" = Fragaria_vesca,
           "Fagaria_ananassa" = Fragaria_ananassa)
          
    })
  
  output$name <- renderText({
    args <- switch(input$organism,
                   "Fragaria_vesca" = "Fragaria Vesca: the Wild Strawberry",
                   "Fragaria_ananassa" = "Fragaria Ananassa: the Garden Strawberry")
  })
  
  output$image <- renderImage({
    args2 <- switch(input$organism,
                    "Fragaria_vesca" =list(
                      src = "www/Fragaria_vesca3.jpg",
                      contentType = "image/jpg",
                      width = 400,
                      height = 300,
                      alt = "Fragaria_vesca"          
                    ),
                    "Fragaria_ananassa" = list(
                      src = "www/Fragaria_ananassa.jpg",
                      contentType = "image/jpg",
                      width = 400,
                      height = 300,
                      alt = "Fragaria_ananassa"
                    )
    )
  }, deleteFile = FALSE)
  readingFile(3)
}
shinyApp(ui, server = server)
