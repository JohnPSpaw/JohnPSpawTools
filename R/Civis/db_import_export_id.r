#John Spaw 
#6/29/18
#Get Wide Table File ID for input to platform modeling 
#Input: db_table name (as string), redshift cluster name (as string)
#Output: Wide Table File ID for input to Civis platform modeling

#' @param db_table Name of table in platform; type = character
#' @param cluster Name of redshift cluster; type = character
#' @param save_path Local path for table to save (temporarily by default); type = character
#' @param delete_local Logical parameter to delete local table (TRUE by default); type = logical 
#'
#' @keywords civis ID import export table wide

db_import_export_id <- function(db_table, #char string
                                cluster,  #char string
                                save_path = '~/Desktop/table_import.csv',
                                delete_local=TRUE #deletes local csv file when done 
                                )
{
  #Load dataframe from database using Civis API
  df <- civis::read_civis(x=db_table,
                  database=cluster
                  )
 
  #Write dataframe to local file
  write.csv(df, 
            save_path
            )
  
  #Upload R object to files endpoint on Civis platform 
  #Returns ID for file to input to modeling job
  civis::write_civis_file(x=save_path)
  
  #Delete local csv file
  if (file.exists(save_path)) file.remove(save_path)
}

#test
#db_import_export_id(db_table = 'psb.disney_msgtestr_train_teen',
#                    cluster = 'redshift-media')



