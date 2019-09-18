library(tidyverse)
library(stringr)
library(data.table)

setwd("~/Javad_Khataei/fish")

#set the specie name
specie_name <- "greatapes"


log_file_name <- paste0(specie_name,"_logfile.csv")
result_file_name <- paste0(specie_name,"_result.txt")
specie_name <- paste0("p(A){1@", specie_name, "}")

df <- fread(paste0("asr_a3f_", specie_name,"_gtr_outgroup_tree.pstat"))
# David verson file name:
df <- fread(paste0("asr_a3f_", specie_name,"_gtr_outgroup_tree_4.pstat"))


#get the first line index
first_line <- which(df$Parameter == specie_name)

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

log$pos <- 1:nrow
log$NT <- result[,1]


result %>% 
    na.omit() %>% 
    write.table(file = result_file_name,
                append = FALSE, sep = "",eol = "",quote = F, row.names = FALSE,
                col.names = FALSE)


# 
# result %>% 
#   na.omit() %>% 
#   fwrite(file = "result_fwrite.txt",
#               append = FALSE, sep ="",eol = "",quote = F, row.names = FALSE,
#               col.names = FALSE)


fwrite(x = log,file = log_file_name, append = F)

