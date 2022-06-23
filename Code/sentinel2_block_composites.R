#  ----
if (!require(utils)) { install.packages('utils') }; require(utils)
if (!require(rasterVis)) { install.packages('rasterVis') }; require(rasterVis)
if (!require(tidyverse)) { install.packages('tidyverse') }; require(tidyverse)
if (!require(stringr)) { install.packages('stringr') }; require(stringr)
if (!require(terra)) { install.packages('terra') }; require(terra)
if (!require(here)) { install.packages('here') }; require(here)
library(collateral)
#


# Unzip your files ----
zips <- list.files(here('Data/s2blocks/'), pattern = '.zip', full.names = T)
map(zips, . %>% unzip(junkpaths = T, exdir = here('Data/s2blocks/extracted')))
#


# Build the manifest ----
manifest <- list.files(here('Data', 's2blocks', 'extracted'),
                       pattern = 'tif$',
                       full.names = T,
                       recursive = T) %>%
  data.frame(full_path = .) %>%
  mutate(base=basename(full_path),
         band = str_extract(base, 'B\\d+A?'),
         ymd = gsub('(\\d{4})(\\d{2})(\\d{2})',
                     '\\1-\\2-\\3',
                     str_extract(base,
                                 '\\d{8}')),
         grid = str_extract(base, '^.{6}'),
         res = rast(full_path) %>%
           res() %>%
           `[[`(1)
  ) %>%
  filter(band %in% c("B02","B03","B04",
                     "B05","B12","B8A"))
#


# Read, split, and gather ----
# This is exactly like the other read_manifest function but less flexible
read_manifest_strong <- function(manifest_obj) {
  manifest_obj %>%
    {map(.$full_path, rast)} %>%
    `names<-`(c("B02","B03","B04",
                "B05","B12","B8A"))
}

# We can now read the selected bands from our manifest keeping the date and grid
nested_imgs <- manifest %>%
  group_by(grid, ymd) %>%
  nest() %>%
  mutate(img = map(data, read_manifest_strong))

# Here you can see all of the bands for all dates exploded into a flat format
full_imgs <- unnest(nested_imgs, cols = c(data, img))

# Now you can circle back to get all of the images grouped by date and grid
full_imgs %>%
  group_by(ymd, grid) %>%
  nest()

# ... or all images from a grid location
full_imgs %>%
  group_by(grid) %>%
  nest()

# ... or all of a certain band for all grids and each date
full_imgs %>%
  filter(band=='B8A') %>%
  group_by(ymd) %>%
  nest()

# Or really any combination you want!

#
