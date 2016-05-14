library(shiny)
library(seqinr)
library(markdown)
library(Rcpp)
library(RMySQL)
sourceCpp('fun.cpp')

loggedIn <<- FALSE

ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap2.css", align = "center")),
  
  align = "left",
  absolutePanel(left = "0%", width = "100%", 
                wellPanel(titlePanel("Zoosh"))),
  
  absolutePanel(left = "0%", top = "8%", width = "100%",
                navbarPage("",
                             tabPanel("Log In",
                                      absolutePanel(left="0%", width="100%", class='login',
                                      titlePanel("Log In/Create Account"),
                                      sidebarPanel(width = 3, 
                                                   textInput("loginEmail", "*Email:", ""),
                                                   passwordInput("loginKey", "*Password:", ""),
                                                   ("*Required fields."),
                                                   br(),
                                                   br(),
                                                   actionButton("doThis", label = "Submit",
                                                                style = "color: #fff; background-color: #337ab7; border-color: #2e6da4")),
                                      sidebarPanel(width = 3,
                                                   align = "right",
                                                   textInput("fname", "*First name:", ""),
                                                   textInput("lname", "*Last name:", ""),
                                                   textInput("comp", "Company/Organization:", ""),
                                                   textInput("email", "*Email:", ""),
                                                   passwordInput("key", "*Password:", ""),
                                                   ("*Required fields."),
                                                   br(),
                                                   br(),
                                                   actionButton("doThisInstead", label = "Submit",
                                                                style = "color: #fff; background-color: #337ab7; border-color: #2e6da4")),
                                      textOutput("testing"),
                                      tags$head(tags$style("#testing{color: black;
                                                           font-size: 20px;
                                                           font-style: bold;}"
                                                           )
                                                )
                                        )),
                           
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
                           tabPanel("Data Visualization", 
                                    "This feature is only available to members of this site.",
                                    uiOutput("plot")
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
                                    containing the genetic data of a species and wait to view the results in which a mutation occured",
                                    tags$hr(),
                                    tags$h2("R"),
                                    tags$iframe(width="560", height="315", src="https://www.youtube.com/embed/TR2bHSJ_eck", frameborder="0", allowfullscreen = "yes"),
                                    tags$br(),
                                    "We decided to use the R language mainly due to how accurately it can display data. Also, the sheer amount of packages available for R is amazing. 
                                    Also, we have some prior experience with R.",
                                    tags$hr(),
                                    tags$h2("Shiny"),
                                    tags$iframe(width="560", height="315", src="https://www.youtube.com/embed/Gyrfsrd4zK0", frameborder="0", allowfullscreen = "yes"),
                                    tags$br(),
                                    "To our amazement, our advisor, Dr. Kim informed us that there is an R package for creating web-based applications. This made our job easier, and harder simply because,
                                    the Shiny package allows for us to display our findings, and create a web application at the same time. However, the shiny package is a little limited in terms of what 
                                    you're able to do with it.",
                                    tags$hr(),
                                    tags$h2("Knuth-Morris-Pratt"),
                                    tags$iframe(width="560", height="315", src="https://www.youtube.com/embed/5i7oKodCRJo", frameborder="0", allowfullscreen = "yes"),
                                    tags$br(),
                                    "We were originally going to use this algorithm as a way to compare two different fasta files. However, we encountered complications with comparing both files.
                                    R requires that files that will be compared need to be of the same size. Since we cannot ensure that users will input files of similar size, we decided to not use the algorithm.",
                                    tags$hr(),
                                    tags$h2("Memory Map"),
                                    tags$iframe(width="560", height="315", src="https://www.youtube.com/embed/F3z-SIxu1Tw", frameborder="0", allowfullscreen = "yes"),
                                    tags$br(),
                                    "This function was going to be used to grab the information straight from each file. This was going to be done using the C++ equivalent of the function, mmap(). However we decided 
                                    to stick to just using R functions to extract the data. The reason why is simply for convenience."
                                    )
                           )
                )
  )

options(shiny.maxRequestSize = 220*1024^2)

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
                      src = "www/Fragaria_vesca.jpg",
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
  
  output$data <- renderUI({
    inFile <- input$dataFile
    if (is.null(inFile))
      return(NULL)
    else
    {
      dat <- read.fasta(inFile$datapath)
      d <- dat[[1]]
      size <- length(d)
      genome <- count(d, 1)
      genome2 <- count(d, 2)
      a <- genome[[1]]
      c <- genome[[2]]
      g <- genome[[3]]
      t <- genome[[4]]
      
      
      title <- paste("DATA INFORMATION:")
      sp <- paste(" ")
      f1 <- paste("Nucleobases: ")
      f2 <- paste("Adenine: ", a)
      f3 <- paste("Cytosine:", c)
      f4 <- paste("Guanine:", g)
      f5 <- paste("Thymine:", t)
      
      HTML(paste(title, sp, f1, f2, f3, f4, f5, sep="<br/>"))
    }
  })
  
  #If information is entered into the log in section
  observe({
    if(input$doThis==0) return()
    
    isolate({
      if(input$loginEmail != "" && input$loginKey != ""){
        if(loggedIn == FALSE){
          mydb = dbConnect(MySQL(), 
                           user='bjolivarez', 
                           password='insertpassword', 
                           dbname='genomeusers', 
                           host='localhost')
          on.exit(dbDisconnect(mydb))
          checking = sprintf("SELECT * FROM `users` WHERE `Email` = \"%s\" AND `Key` = \"%s\";", input$loginEmail, input$loginKey)
          rs = dbSendQuery(mydb, checking)
          data = fetch(rs, n = 20)
          dbClearResult(rs)
          if(nrow(data) != 0){
            loggedIn <<- TRUE
            output$testing = renderText("You are now logged in!")
            output$plot = renderUI(
              absolutePanel(width="100%", left = "0%", wellPanel(
                #tableOutput('contents')
                htmlOutput('data'),
                tags$br(), 
                plotOutput("dataPlot"), 
                tags$br(), 
                "CODONS:",
                tags$br(), 
                htmlOutput('data2'), 
                tags$br(), plotOutput("dataPlot2")
              ))
            )
          } else {
            output$testing = renderText("The email or password is incorrect.")
          }
        } else {
          output$testing = renderText("You are already logged in!")
        }
      } else {
        output$testing = renderText("Must enter characters in required textboxes.")
        
      }
    })
  })
  
  output$dataPlot <- renderPlot({
    inFile <- input$dataFile
    if (is.null(inFile))
      return(NULL)
    else
    {
      dnafile <- read.fasta(inFile$datapath)
      #length(dnafile)
      n1<-dnafile[[1]]
      table1 <- count(n1,1) #counts the number of nucleotides
      table2 <- count(n1,3) #counts the number of trinucleotides
      GC(n1) #GC content
      annotation <- getAnnot(dnafile) #storing the fasta header
      
      
      #graphs for the fragaria vesca
      barplot(table1, main="Nucleobase Count", xlab="Nucleobases",las=1, col=blues9)
    }
  })
  
  output$dataPlot2 <- renderPlot({
    inFile <- input$dataFile
    if (is.null(inFile))
      return(NULL)
    else
    {
      dnafile <- read.fasta(inFile$datapath)
      #length(dnafile)
      n1<-dnafile[[1]]
      table1 <- count(n1,1) #counts the number of nucleotides
      table2 <- count(n1,3) #counts the number of trinucleotides
      GC(n1) #GC content
      annotation <- getAnnot(dnafile) #storing the fasta header
      
      #graphs for the fragaria vesca
      barplot(table2, main="Codon Count", xlab="Codons", las=1, col=blues9)
    }
  })
  
  output$data2 <- renderUI({
    inFile <- input$dataFile
    if (is.null(inFile))
      return(NULL)
    else
    {
      dat <- read.fasta(inFile$datapath)
      d <- dat[[1]]
      genome3 <- count(d, 3)
      
      title <- paste("AminoAcids:")
      sp <- paste(" ")
      
      #get count of different codons
      amino <- read.csv("aminoacids.txt", header = FALSE, sep = ",", 
                        col.names = paste0("V",seq_len(8)), fill = TRUE)
      
      c <- read.csv("codon.txt")
      co <- c[[1]]
      cod <- matrix(co)
      geno <- matrix(genome3)
      
      grows <- nrow(geno) #get number of rows for codon count
      crows <- nrow(cod) #get number of rows for codons
      
      colon <- paste(":")
      bar <- paste("|")
      
      HTML(paste(sp, cod[1:crows, 1], colon, geno[1:grows, 1], bar))
    }
  })
  
  
  #If Information is entered into new account section.
  observe({
    if(input$doThisInstead==0) return()
    
    isolate({
      if(input$fname != "" && input$lname != "" && input$email != "" && input$key != ""){
        if(loggedIn == FALSE){
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
            output$testing = renderText("")
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
            output$testing = renderText("Account created! Please enter your credentials in the log in section.")
          }
          else{
            output$testing = renderText("That email is already taken, please try another one.")
          }
        }else{
          output$testing = renderText("You are already logged in!")
          
        }
      }
      else{
        output$testing = renderText("Must enter characters in required textboxes.")
      }
    })
  })
}

shinyApp(ui, server = server)


