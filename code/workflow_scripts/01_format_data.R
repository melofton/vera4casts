#Format data for each model and fit models from 2018-2021
#Author: Mary Lofton
#Date: 26SEP23

#Purpose: format historical FCR + BVR data for input into forecast models

library(tidyverse)
library(lubridate)

#Load data formatting functions
data.format.functions <- list.files("./code/function_library/format_data")
sapply(paste0("./code/function_library/format_data/", data.format.functions),source,.GlobalEnv)

#Define targets filepath
targets <- "https://renc.osn.xsede.org/bio230121-bucket01/vera4cast/targets/daily/exo_daily-targets.csv.gz"

#Define start and end dates (needed for interpolation)
end_date = Sys.Date()

#Format data
dat_ETS <- format_data_ETS(targets = targets,
                           end_date = end_date)

#Write processed data to file
write.csv(dat_ETS, "./data/processed_targets/ETS.csv",row.names = FALSE)

