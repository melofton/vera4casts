#fableETS
#Author: Mary Lofton
#Date: 26SEP23

#Purpose: make predictions with ETS model

library(fable)

#'Function to fit day of year model for chla
#'@param data data frame with columns Date (yyyy-mm-dd) and
#'median daily EXO_chla_ugL_1 with chl-a measurements in ug/L

data <- dat_ETS

fableETS <- function(data, reference_datetime, forecast_horizon){
  
  #assign target and predictors
  df <- data %>%
    select(-depth_m, -variable) %>%
    as_tsibble(key = site_id, index = datetime)
  
  #fit ARIMA from fable package
  my.ets <- df %>%
    model(ets = fable::ETS(observation)) 
  fitted_values <- fitted(my.ets)
  
  #build output df
  df.out <- data.frame(site_id = df$site_id,
                       model_id = "ETS",
                       datetime = df$datetime,
                       variable = "Chla_ugL",
                       depth_m = 1.6,
                       observation = df$observation,
                       prediction = fitted_values$.fitted)
  
  #get process error
  sd_resid <- sd(df.out$prediction - df.out$observation)
  
  #create "new data" dataframe
  fc_dates <- seq.Date(from = reference_datetime, to = reference_datetime + forecast_horizon, by = "day")
  new_data <- tibble(datetime = rep(fc_dates,times = 2),
                      site_id = rep(unique(df.out$site_id), each = length(fc_dates)),
                      observation = NA) %>%
    as_tsibble(key = site_id, index = datetime)
  
  #make forecast
  fc <- forecast(my.ets, new_data = new_data, bootstrap = TRUE) %>%
    autoplot()
  fc

  #return output + model with best fit + plot
  return(list(out = df.out, ETS = my.ets, plot = ETS_plot))
}
