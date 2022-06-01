# META ----
# Title:  Default setup for fainjj
# First Created: Thu May 20 10:46:25 2021
#
# NOTES ----
#'
#

# Setup ----
if (!require(raster)) { install.packages('raster') }; require(raster)
if (!require(tidyverse)) { install.packages('tidyverse') }; require(tidyverse)
if (!require(here)) { install.packages('here') }; require(here)
if (!require(sf)) { install.packages('sf') }; require(sf)
#

options(stringsAsFactors = T)


# Extract Validation Data ----
val_data <- here('Data', 'Africa_LC_Checks') %>%
  list.files(pattern = 'xlsx$', full.names = T) %>%
  map(readxl::read_xlsx)

# Get the Validated LC classes ()
val_data[[1]] <- select(val_data[[1]], IGBP_Name, Validated_LC)
val_data[[2]] <- select(val_data[[2]], IGBP_Name, Validated_LC)
val_data[[3]] <- select(val_data[[3]], IGBP_Name, LC_Class)
val_data[[4]] <- select(val_data[[4]], IGBP_Name, Validated)

names(val_data[[3]]) <- c('IGBP_Name', 'Validated_LC')
names(val_data[[4]]) <- c('IGBP_Name', 'Validated_LC')

lc_val_data <- data.table::rbindlist(val_data) %>% {.[complete.cases(.), ]}
#


# Extract LUT and make confusion matrices ----
lut <- read_csv('/Volumes/Yggdrasil/Projects/AMAP/Data/em_ef2.csv')

lc_val_data$IGBP_Name <- factor(lc_val_data$IGBP_Name, levels =  lut$IGBP_Name)
lc_val_data$Validated_LC <- factor(lc_val_data$Validated_LC, levels =  lut$IGBP_Name)

over_val <- table(lc_val_data) %>% as.matrix() %>% {(diag(.)/colSums(.))*100}
over_pred <- table(lc_val_data) %>% as.matrix() %>% {(diag(.)/rowSums(.))*100}
#
