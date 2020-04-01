getwd()
library(tidyverse)
library(data.table)
library(plotly)

df <- fread("Downloads/Gm-AID.txt", header =  T)
df$AmAcid <- paste0(df$AmAcid,"-Gm")
df$sp <- "Gm"

df2 <- fread("Downloads/Dr-AID.txt", header = T)
df2$AmAcid <- paste0(df2$AmAcid,"-Dr")
df2$sp <- "Dr"

df3 <- fread("Downloads/Hs-AID.txt", header = T)
df3$AmAcid <- paste0(df3$AmAcid,"-Hs")
df3$sp <- "Hs"

df4 <- fread("Downloads/Ip-AID.txt", header = T)
df4$AmAcid <- paste0(df4$AmAcid,"-Ip")
df4$sp <- "Ip"

df5 <- fread("Downloads/Pj-AID.txt", header = T)
df5$AmAcid <- paste0(df5$AmAcid,"-Pj")
df5$sp <- "Pj"

df <- bind_rows(df,df2,df3,df4,df5)

df <- df %>%  arrange(AmAcid, Codon)

df$bar_text <- paste0(df$Codon," (",df$Fraction*100,")") 


# maybe useful
df <- df %>% group_by(AmAcid) %>% mutate(id = row_number())

# find position for text
df$pos <- df$Fraction / 2
for (i in 2:nrow(df)) {
  if (df$AmAcid[i] == df$AmAcid[i-1]){
    df$pos[i] = df$pos[i-1] + df$Fraction[i-1] / 2 + df$Fraction[i] / 2

  }
  else{
    df$pos[i] = df$Fraction[i] / 2
  }
  
}


#plotly didn't let me save. orca is not working. maybe need a restart
# 
# 
# t <- list(
#     family = "sans serif",
#     size = 8,
#     color = 'black')
# 
# fig2 <- plot_ly(df, x = ~AmAcid , y = ~Fraction, type = "bar", color = ~id,
#                 textposition = 'inside',
#                 marker = list(colorscale = 'Inferno',
#                               line = list(color = 'rgb(8,48,107)',
#                                           width = 1.5)))
# fig2 <- fig2 %>% layout(yaxis = list(title = 'Fraction'), barmode = 'stack')
# fig2 <- fig2 %>% add_annotations(text =  ~Codon, x = ~AmAcid, y = ~pos,
#                                  showarrow = FALSE , textangle= '-90',
#                                  font = t)
# 
# fig2
#     
# orca(p = fig2, file = "/test.jpg")
# export(fig2, file = "image.png")
# getwd(
#     
# )




# library
library(ggplot2)
library(viridis)
library(wesanderson)


ggplot(df, aes(color=Codon, y=Fraction, x=AmAcid)) + 
    geom_bar(position="fill", stat="identity") +
    facet_wrap(~sp)

pal <- wes_palette("Moonrise3", 7, type = "continuous")


ggplot(df, aes(fill=id, y=Fraction, x=AmAcid)) + 
    geom_bar(position="fill", stat="identity") +
    theme(legend.position = "none") +
    scale_fill_gradientn(colours = pal) +
    geom_text(aes(label=bar_text,y=pos, x=AmAcid, angle = -90), size = 3) +
    theme(axis.text.x = element_text(hjust = 0.5, angle = -90)) +
    theme(axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank())


fwrite(x = df, "df_prepared.csv")

# Check this for palletes
