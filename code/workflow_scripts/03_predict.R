#Predict chl-a
#Author: Mary Lofton
#Date: 26SEP23

#Purpose: predict EXO chl-a 30 days into future at FCR and BVR

library(tidyverse)
library(lubridate)

# Install VERA helpers package if have not already done so
remotes::install_github("LTREB-reservoirs/vera4castHelpers")
library(vera4castHelpers)

#Load prediction functions
predict.model.functions <- list.files("./code/function_library/predict")
sapply(paste0("./code/function_library/predict/",predict.model.functions),source,.GlobalEnv)

#Read in data
dat_ETS <- read_csv("./data/processed_targets/ETS.csv")

#Set prediction window and forecast horizon
reference_datetime <- Sys.Date()
forecast_horizon = 30

#Predict chl-a
pred_ETS <- fableETS(data = dat_ETS,
                     reference_datetime = reference_datetime,
                     forecast_horizon = forecast_horizon)

# Start by writing the filepath
theme <- 'daily'
date <- pred_ETS$reference_datetime[1]
forecast_name <- paste0(pred_ETS$model_id[1], ".csv")

# Write the file locally
forecast_file <- paste(theme, date, forecast_name, sep = '-')
forecast_file

forecast_file1 <- paste0("./model_output/",forecast_file)
forecast_file1

# write to file
write.csv(pred_ETS, forecast_file1, row.names = FALSE)

# validate
vera4castHelpers::forecast_output_validator(forecast_file1, target_variables = c("Chla_ugL"), theme_names = c("daily"))
vera4castHelpers::submit(forecast_file1, s3_region = "submit", s3_endpoint = "ltreb-reservoirs.org", first_submission = TRUE)

df <- readr::read_csv(forecast_file1, show_col_types = FALSE)
model_id <- df$model_id[1]

if(grep("(example)",model_id)){
  message(paste0("You are submitting a forecast with 'example' in the model_id. As a example forecast, it will be processed but only retained for 30-days.\n",
                 "No registration is required to submit an example forecast.\n",
                 "If you want your forecast to be retained, please select a different model_id that does not contain `example` and register you model id at https://forms.gle/kg2Vkpho9BoMXSy57\n"))
}
