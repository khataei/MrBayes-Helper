library(shiny)
library(tidyverse)
library(stringr)
library(data.table)

# Define UI for data upload app ----
ui <- fluidPage(
    
    # App title ----
    titlePanel("MrBayes Helper"),
    
    # Sidebar layout with input and output definitions ----
    sidebarLayout(
        
        # Sidebar panel for inputs ----
        sidebarPanel(
            
            
            textInput("spe_name","Enter the species name first:"),
            tags$hr(),
            
            # Input: Select a file ----
            fileInput("file1", "Open your pstat file",
                      multiple = FALSE,
                      accept = c("text/pstat",
                                 "text/comma-separated-values,text/plain",
                                 ".pstat")),
            
            
            # Horizontal line ----
            tags$hr(),
            
            # Button
            downloadButton("CreateLog", "Create log file"),
            downloadButton("CreateResult", "Create Results file")
            
            
        ),
        
        # Main panel for displaying outputs ----
        mainPanel(
            
            # Output: Data file ----
            tableOutput("contents")
            
        )
        
    )
)

# Define server logic to read selected file ----
server <- function(input, output) {
    
    output$contents <- renderTable({
        
        # input$file1 will be NULL initially. After the user selects
        # and uploads a file, head of that data file by default,
        # or all rows if selected, will be shown.
        
        req(input$file1)
        
        ##################### Main script ########################

        

        #set the specie name
        species_name <- input$spe_name
    
        species_name <- paste0("p(A){1@", species_name, "}")
        
        df <- fread(input$file1$datapath)

        
        #get the first line index
        first_line <- which(df$Parameter == species_name)
        
        #get the last line index
        last_line <- length(df$Parameter)
        
        #select the important part
        df <- df[first_line:last_line,]
        
        #add the position and letter column  
        df <-df %>%
            mutate(position = df$Parameter %>%
                       str_match("[0-9]+") %>%
                       as.integer(),
                   NT = df$Parameter %>%
                       str_sub(start = 3, end = 3)
            )
        
        
        #narrow down the dataset
        df <-df %>%
            select(position, NT , Mean)
        
        
        #order based on position
        df <- setorder(x = df ,cols = position)
        #reset rows names
        rownames(df) <- NULL
        
        
        #create log and result empty dataframe
        nrow <- df %>%  nrow() / 4
        log <- data.frame(matrix(nrow = nrow , ncol = 4))
        colnames(log) <- c("pos","NT","state" , "probability")
        result <- data.frame(matrix(nrow = nrow , ncol = 1))
        highest <- data.frame(matrix(nrow = nrow , ncol = 1))
        colnames(result) <- NULL
        
        df$position %>%  
            unique() %>% 
            map(function(i){
                chunk <- df %>%
                    filter(df$position == i)
                
                chunk <- chunk[order(chunk$Mean, decreasing = TRUE),]
                
                if (chunk$Mean[1] > 0.8 ) {
                    log[i,3] <<- "Single"
                    result[i,1] <<- chunk$NT[1]
                    highest[i,1] <<- chunk$NT[1]
                    
                }
                else {
                    if ((chunk$Mean[1] + chunk$Mean[2]) > 0.8) {
                        log[i,3] <<- "Double"
                        log[i,4] <<- paste0(chunk$NT[1]," _P=", chunk$Mean[1],
                                            "___",chunk$NT[2]," _P=",
                                            chunk$Mean[2])
                        
                        result[i,1] <<- paste0(chunk$NT[1],"/",chunk$NT[2])
                        highest[i,1] <<- chunk$NT[1]
                        
                    }
                    else {
                        if ((chunk$Mean[1] + chunk$Mean[2] +  chunk$Mean[3]) > 0.85) {
                            log[i,3] <<- "Triple"
                            log[i,4] <<- paste0(chunk$NT[1]," _P=", chunk$Mean[1],
                                                "___",chunk$NT[2]," _P=",
                                                chunk$Mean[2], "___",chunk$NT[3]," _P=",
                                                chunk$Mean[3])
                            result[i,1] <<- paste0(chunk$NT[1],"/",chunk$NT[2],"/", chunk$NT[3])
                            highest[i,1] <<- chunk$NT[1]
                            
                        }
                        else {
                            log[i,3] <<- "Gap"
                        }
                    }
                }
                
                
            })
        
        
        # outputs are ready here:
        log$pos <- 1:nrow
        log$NT <- result[,1]
        
        # store with <<- to use it in download section
        log_file_content <<- log
        
        result_file_content <<- result %>% 
            na.omit()
        

        return(head(log,n = 50))
    })
    
    # Downloadable csv of selected dataset ----
    output$CreateLog <- downloadHandler(
        filename = function() {
            #set the specie name
            species_name <- input$spe_name
            paste0(species_name,"_logfile.csv")
        },
        content = function(file) {
            fwrite(x = log_file_content, file, append = F)
            #write.csv(datasetInput(), file, row.names = FALSE)
        }
    )
    # Downloadable text of selected dataset ----
    output$CreateResult <- downloadHandler(
        filename = function() {
            #set the specie name
            species_name <- input$spe_name
            paste0(species_name,"_result.txt")
            
        },
        content = function(file) {
                write.table(result_file_content , file ,
                            append = FALSE, sep = "",eol = "",quote = F, row.names = FALSE,
                            col.names = FALSE)
                    }
    )
    
}

# Create Shiny app ----
shinyApp(ui, server)