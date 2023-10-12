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

source("./code/workflow_scripts/01_format_data.R")
source("./code/workflow_scripts/03_predict.R")


