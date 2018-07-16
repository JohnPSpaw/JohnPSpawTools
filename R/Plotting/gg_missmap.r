#John Spaw
#Inspired by Nicholas Tierney
#Create plot of missing data 

library(dplyr)
library(reshape2)
library(ggplot2)
library(ggthemes)

ggplot_missing <- function(x){
  x %>% 
    is.na %>%
    melt %>%
    ggplot(data = .,
           aes(x = Var2,
               y = Var1)) +
    geom_raster(aes(fill = value)) +
    scale_fill_grey(name = "",
                    labels = c("Present","Missing")) +
    theme_fivethirtyeight() + 
    theme(axis.text.x  = element_text(angle=45, vjust=0.5)) + 
    labs(x = "Variables in Dataset",
         y = "Rows / observations")
}
