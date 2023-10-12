# Install R packages
# Author: Mary Lofton
# Date: 12OCT23

# Purpose: install R packages that aren't already in neon4cast rocker

remotes::install_github("LTREB-reservoirs/vera4castHelpers", force = TRUE)
install.packages("tidyverse")
install.packages("lubridate")
install.packages("zoo")
install.packages("fable")
install.packages("feasts")
install.packages("urca")