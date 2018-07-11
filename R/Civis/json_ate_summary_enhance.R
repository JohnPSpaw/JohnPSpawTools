library(dplyr)
library(magrittr)

###Convert json list to dataframe
########################################################
#Load model results from local JSON file
local_json_path <- "model_results/Full/msgexp_results_full.json"  ### USER
results <- (rjson::fromJSON(file = local_json_path))[[1]]

#create empty matrix
n <- length(results) #number of rows in summary table
p <- length(results[[1]]) #number of columns in summary table
results_df <- matrix(NA, nrow=n, ncol=p)

#populate entries of matrix from results list
for(i in 1:n) {results_df[i,] <- unlist(results[[i]])}

#Convert to df and rename columns
results_df <- as.data.frame(results_df)
names(results_df) <- names(results[[1]])
rm(results)


###Remove rows where DV and treatment don't match
  ###CHECK: for different applications, this section may be substantially different 
  ###results_df should pass this section without any irrelevent DV/treatment mismatch
########################################################
#Flag rows with treatment mismatch indicator
results_df$trt_mismatch <- case_when(
  grepl("nutcracker", results_df$dvs) & !(grepl("Nutcracker", results_df$treatment) | grepl("Control", results_df$treatment)) ~ 1,
  grepl("marypoppins", results_df$dvs) & !(grepl("Mary", results_df$treatment) | grepl("Control", results_df$treatment)) ~ 1,
  grepl("ralph", results_df$dvs) & !(grepl("Ralph", results_df$treatment) | grepl("Control", results_df$treatment)) ~ 1
)

#Remove rows with mismatch flag and omit mismatch flag column
results_df %<>% 
  filter(is.na(trt_mismatch)) %>% #remove rows with mismatch
  select(-one_of("trt_mismatch")) #remove trt mismatch column


###Add control topline to treated subgroups
###Split data frame in control and treated. Rejoin on dvs, subgroup_label, and subgroup
###USER specifies label for control treatment group
########################################################
#Control
control_label <- "Control" ### USER
control_df <- results_df %>% 
  subset(treatment == control_label) %>%
  select("dvs", "subgroup_label", "subgroup", "topline")
names(control_df)[4] <- "control_topline"

#Treated 
treated_df <- results_df %>% 
  subset(treatment != control_label)

#Join tables and reorder columns
ate_df <- left_join(treated_df,
                    control_df,
                    by = c("dvs" = "dvs", "subgroup_label" = "subgroup_label", "subgroup" = "subgroup")
                    )
ate_df <- ate_df[,c(1:5,14,6:13)]

#Remove unnecessary dfs
rm(list = c('control_df','results_df','treated_df'))


###Add subgroup counts
  ###USER specifies db and cluster for survey load
############################
#Load original table of survey responses using Civis API
db_table <- "psb.disney_msgtestr_train" #USER
cluster <- "redshift-media" #USER
survey_df <- civis::read_civis(x=db_table, database=cluster)

#Create collection of all unique subgroups
subgroups <- ate_df %>% select("subgroup_label", "treatment","subgroup")

#Empty vector container for subgroup counts
counts <- rep(NA,nrow(subgroups))

#Need to skip 'overall' rows in for loop ... specify row indices
overall_skip <- which(ate_df$subgroup_label == "overall")

#Overall counts
#THIS WILL VARY WITH OTHER APPLICATIONS
trt_overall_counts <- plyr::count(survey_df, "treatment_group")
nut_count <- trt_overall_counts$freq[3]
ralph_count <- trt_overall_counts$freq[4]
mp_count <- trt_overall_counts$freq[2]

#update skipped overall counts
#THIS WILL VARY WITH OTHER APPLICATIONS
counts[overall_skip] <- c(nut_count, ralph_count, mp_count, nut_count, ralph_count, mp_count)

#iterate through all unique subgroup/treatment combos (except overall) and count membership
for(s in 1:nrow(subgroups)) {
  #skip subgroups with 'overall'
  if(s %in% overall_skip) next
  
  #extract specific group values 
  subgroup <- as.character(subgroups[s,1])
  trt <- subgroups[s,2]
  subgroup_label <- as.character(subgroups[s,3])
  
  #reduce survey dataset to match subgroup, treatment, and specific subgroup label
  trt_condition <- survey_df[,2] == trt #does the survey level treatment match the composite subgroup treatment?
  subgroup_colnum <- match(subgroup,names(survey_df)) #find the survey level column number corresponding to the subgroup
  subgroup_label_condition <- as.character(survey_df[,subgroup_colnum]) == subgroup_label #does the value in the survey subgroup column match the subgroup label
  count_condition <- trt_condition & subgroup_label_condition #composite of treatment and subgroup_label conditions ... TRUE indicates composite subgroup membership
  
  #Sum across subgroup membership logical indicators
  counts[s] <- sum(count_condition)
}

#Join counts to ATE table
ate_df$n <- counts


###Export to csv
########################################################
directory <- "reports/"
name <- "ates_full"
extension <- ".csv"
write.csv(x = ate_df,
          file = paste0(directory, name, extension)
)

#Remove unused tables
### DO THIS LATER













