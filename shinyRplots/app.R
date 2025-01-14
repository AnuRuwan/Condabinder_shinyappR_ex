library(shiny)



# Define UI for application that draws a histogram
ui <- fluidPage(
    
    # Application title
    titlePanel("Shinyplots exercise"),
    
    
    
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            
            
            # Input: Select a file ----
            fileInput("file1", "Choose CSV File",
                      multiple = FALSE,
                      accept = c("text/csv",
                                 "text/comma-separated-values,text/plain",
                                 ".csv")),
            
            # Horizontal line ----
            tags$hr(),
            
            
            
            # Input: Checkbox if file has header ----
            checkboxInput("header", "Header", TRUE),
            
            # Input: Select separator ----
            radioButtons("sep", "Separator",
                         choices = c(Comma = ",",
                                     Semicolon = ";",
                                     Tab = "\t"),
                         selected = ","),
            
            # Input: Select quotes ----
            radioButtons("quote", "Quote",
                         choices = c(None = "",
                                     "Double Quote" = '"',
                                     "Single Quote" = "'"),
                         selected = '"'),
            
            # Horizontal line ----
            tags$hr(),
            
            # Input: Select number of rows to display ----
            radioButtons("disp", "Display",
                         choices = c(Head = "head",
                                     All = "all"),
                         selected = "head"),
            
            # adding an action button
            actionButton("go", "Linear model"),
        ),
        
        
        
        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("distPlot"),
            plotOutput("linearplot"),
            tableOutput("contents"),
            tableOutput("lmtable"),    # table added
            h5("correlation coefficient r2"),
            verbatimTextOutput("corr") # text box added
            
            
        )
    )
)


# Define server logic required to draw a histogram
server <- function(input, output) {
    
    dataInput <- reactive({
        req(input$file1)
        
        df <- read.csv(input$file1$datapath,
                       header = input$header,
                       sep = input$sep,
                       quote = input$quote)
        return(df)
    })
    
    reg <- reactive({
        lm(dataInput()$y ~ dataInput()$x) # liner model
    })
    
    corr<- reactive({
        cor(dataInput()$x, dataInput()$y) # correlation coeficient
    })
    
    output$distPlot <- renderPlot({
        plot(dataInput()$x,dataInput()$y) 
    })
    
    observeEvent(input$go, {
        output$linearplot <- renderPlot({
            x <- dataInput()$x
            y <- dataInput()$y
            plot(x,y)
            abline(reg ())
        })
        
        
    })
    
    output$contents <- renderTable({
        
        # input$file1 will be NULL initially. After the user selects
        # and uploads a file, head of that data file by default,
        # or all rows if selected, will be shown.
        
        
        if(input$disp == "head") {
            return(head(dataInput()))
        }
        else {
            return(dataInput())
        }
        
    })
    
    output$lmtable <- renderTable({
        data.frame( intercept = coef(reg())[1],
                    slope = coef(reg())[2]
        )
    }) # table for intercept and gradient
    
    output$corr <- renderText({ corr () }) # text box for corr coef:
}




# Run the application 
shinyApp(ui = ui, server = server)
