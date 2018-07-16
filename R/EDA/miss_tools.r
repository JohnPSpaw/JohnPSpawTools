#John Spaw
#Set of functions to summarize missingness by column 

require(dplyr)

miss_count <- function(df) {
  miss_df <- df %>% 
    is.na() %>%
    apply(MARGIN = 2, sum) %>%
    sort(decreasing = TRUE)
  
  return(miss_df)
}

miss_mean <- function(df, 
                      percent = TRUE) {
  miss_df <- df %>% 
    is.na() %>%
    apply(MARGIN = 2, mean) %>%
    sort(decreasing = TRUE) %>%
    round(4)
    
  if(percent == TRUE) {
    miss_df %<>% scales::percent()
  }

  return(miss_df)  
}
