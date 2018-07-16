#John Spaw
#Inspired by Nicholas Tierney
#Create plot of missing data 

require(dplyr)
require(reshape2)
require(ggplot2)
require(ggthemes)

ggplot_missing <- function(x){
  plot_colors <- c("#22556F", "#FCB729") 
  x %>% 
    is.na %>%
    melt %>%
    ggplot(data = .,
           aes(x = Var2,
               y = Var1)) +
    geom_raster(aes(fill = value)) +
    scale_fill_manual(values = plot_colors) +
    #scale_fill_grey(name = "",
    #                labels = c("Present","Missing")) +
    theme_fivethirtyeight() + 
    theme(axis.text.x  = element_text(angle=45, vjust=0.5)) + 
    labs(x = "Variables in Dataset",
         y = "Rows / observations")
}
