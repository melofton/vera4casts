# Workflow script
# Author: Mary Lofton
# Date: 12OCT23

# Purpose: run forecasting workflow for VERA

# install R packages that aren't already in neon4cast rocker
install.packages("remotes")
install.packages("tidyverse")
install.packages("lubridate")
install.packages("zoo")
install.packages("fable")
install.packages("feasts")
install.packages("urca")
library(remotes)
remotes::install_github("LTREB-reservoirs/vera4castHelpers", force = TRUE)

library(tidyverse)
library(tsibble)
library(aws.s3)

# check for any missing forecasts
message("==== Checking for missed forecasts ====")
challenge_model_names <- c('fableARIMA','fableETS','fableNNETAR')

# Dates of forecasts 
today <- paste(Sys.Date() - days(2), '00:00:00')
dates = as.character(paste0(seq.Date(as_date('2023-10-01'), to = as_date(today), by = 'day'), ' 00:00:00'))
this_year <- matrix(data = NA, nrow = length(challenge_model_names), ncol = length(dates)+1)
this_year <- data.frame(this_year)
colnames(this_year) <- c("model_id",dates)
this_year$model_id <- challenge_model_names
  
# vera bucket
s3 <- arrow::s3_bucket("bio230121-bucket01/vera4cast/inventory/catalog",
                       endpoint_override = "renc.osn.xsede.org",
                       anonymous = TRUE)

submitted_forecasts_df <- arrow::open_dataset(s3) |> 
  filter(model_id %in% challenge_model_names) |>
  collect()

# is that forecast present in the bucket?
for (i in 2:ncol(this_year)) {
  
  for(j in 1:length(challenge_model_names)){
  
  models_submitted <- unique(submitted_forecasts_df %>%
    filter(reference_date == dates[i]) %>%
    pull(model_id))

  this_year[j,i] <- ifelse(challenge_model_names[j] %in% models_submitted,T,F)
  
  }
  
}

# wrangle back to long format
this_year_long <- this_year %>%
  pivot_longer(!model_id, names_to = "date", values_to = "exists")

# which dates do you need to generate forecasts for?
# those that are missing or haven't been submitted
missed_dates <- this_year_long |> 
  filter(!(exists == T)) |> 
  pull(date) |> 
  as_date() |>
  unique()

if (length(missed_dates) != 0) {
  for (i in 1:length(missed_dates)) {
    
    curr_reference_datetime <- missed_dates[i]
    
    message(paste("creating forecasts for",print(curr_reference_datetime)))
    
    # download the noaa once then apply the forecasts
    source("./code/workflow_scripts/01_format_data.R")
    message('data formatted!')
    
    # Script to run forecasts
    source("./code/workflow_scripts/03_predict.R")
    message('forecasts submitted!')
    
  }
} else {
  message('no missed forecasts')  
}



