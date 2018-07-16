#John Spaw
#Set of functions to summarize missingness by column 

require(dplyr)

miss_count <- function(df) {
  miss_df <- df %>% 
    is.na() %>%
    apply(MARGIN = 2, sum) %>%
    sort(decreasing = TRUE)
  
}

miss_mean <- function(df) {
  miss_df <- df %>% 
    is.na() %>%
    apply(MARGIN = 2, mean) %>%
    sort(decreasing = TRUE)
}
