library(collateral)
library(gdalUtils)
library(tidyverse)
library(terra)
library(here)

mcd_files <- list.files(here('Data/mcd12q1/'), pattern = 'hdf$', full.names = T)

mcd_file_year <- str_extract(mcd_files, pattern = '\\d{4}')

mcd_file_outnames <- paste0('year', mcd_file_year, '_', basename(mcd_files), '.tif') %>%
  str_remove_all('.hdf') %>%
  {here('Outs', .)}

extract_first_layer <- function(fpath) {
  return(sds(fpath)[1])
}

all_files <- map_peacefully(mcd_files, extract_first_layer)

for(i in 1:length(all_files)) {
  ifelse(!is.null(all_files[[i]]$result),
         writeRaster(all_files[[i]]$result, mcd_file_outnames[i], overwrite = T),
         next)
}


for(y in paste0('year', unique(mcd_file_year))) {
  list.files(here('Outs'), pattern = y, full.names = T) %>%
    map(rast) %>%
    src() %>%
    mosaic() %>%
    {writeRaster(.,
                 here('Outs',
                      paste0(y, '_landcover', '.tif')),
                 overwrite=TRUE)}
}

list.files(here('Outs'), pattern = 'year2016', full.names = T) %>%
  map(rast) %>%
  src() %>%
  mosaic() %>%
  {writeRaster(.,
               here('Outs',
                    paste0('year2016', '_landcover', '.tif')),
               overwrite=TRUE)}
