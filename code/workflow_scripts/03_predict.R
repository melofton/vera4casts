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
dat_ARIMA <- read_csv("./data/processed_targets/ARIMA.csv")
dat_NNETAR <- read_csv("./data/processed_targets/NNETAR.csv")


#Set prediction window and forecast horizon
reference_datetime <- Sys.Date()
forecast_horizon = 30

#Predict chl-a
pred_ETS <- fableETS(data = dat_ETS,
                     reference_datetime = reference_datetime,
                     forecast_horizon = forecast_horizon)
pred_ARIMA <- fableARIMA(data = dat_ARIMA,
                     reference_datetime = reference_datetime,
                     forecast_horizon = forecast_horizon)
pred_NNETAR <- fableNNETAR(data = dat_NNETAR,
                     reference_datetime = reference_datetime,
                     forecast_horizon = forecast_horizon)

# Start by writing the filepath
theme <- 'daily'
date <- Sys.Date()

# LEFT OFF HERE
# decide whether you really want to for-loop this or not, if you do
# you probably need to make a for-loop above so the forecasts from
# different models are elements in a list that can be referenced
# in the forecast here

forecast_names <- c(paste0(pred_ETS$model_id[1], ".csv"),
                    paste0(pred_ARIMA$model_id[1], ".csv"),
                    paste0(pred_NNETAR$model_id[1], ".csv"))

for(i in 1:length(forecast_names)){

# Write the file locally
forecast_file <- paste(theme, date, forecast_names[i], sep = '-')
forecast_file

forecast_file1 <- paste0("./model_output/",forecast_file)
forecast_file1

# write to file
write.csv(pred_ETS, forecast_file1, row.names = FALSE)

# validate
vera4castHelpers::forecast_output_validator(forecast_file1, target_variables = c("Chla_ugL"), theme_names = c("daily"))
vera4castHelpers::submit(forecast_file1, s3_region = "submit", s3_endpoint = "ltreb-reservoirs.org", first_submission = TRUE)

}
