if (!require(stars)) { install.packages('stars') }; require(stars)
if (!require(raster)) { install.packages('raster') }; require(raster)
if (!require(spatialEco)) { install.packages('spatialEco') }; require(spatialEco)

ras2poly <- function(ras) {sf::as_Spatial(sf::st_as_sf(stars::st_as_stars(ras), as_points = FALSE, merge = TRUE))}

aoi_lc <- raster('/Users/fainjj/Desktop/tmp/aoi_lc.tif')

# aoi_lc_masks <- map(unique(values(aoi_lc)), . %>% `==`(aoi_lc, .))
# names(aoi_lc_masks) <- unique(values(aoi_lc))
# aoi_lc_polys <- map(aoi_lc_masks, ras2poly)

#  ----
aoi_lc_polys_full <- ras2poly(aoi_lc)
names(aoi_lc_polys_full) <- 'IGBP'

writeOGR(aoi_lc_polys_full, '/Users/fainjj/Desktop/tmp/aoi_lc_polys.shp', layer = 'LC', driver = 'ESRI Shapefile')
#


#  ----
set.seed(1000)

srsamp <- aoi_lc_polys_full %>%
  st_as_sf() %>%
  mutate(Area = st_area(.)) %>%
  filter(Area > units::as_units((500^2)*3, 'm^2'), Area < units::as_units((500^2)*1000, 'm^2')) %>%
  as_Spatial() %>%
  stratified.random('IGBP', n = 70, reps = 4, replace = F)

# c('Cabrera', 'Somers', 'Lubanovic', 'Zamanialaei', 'Fain', 'McCarty')
assigned_alcs <- srsamp %>%
  st_as_sf() %>%
  mutate(Tech = rep_len(c('Cabrera', 'Somers', 'Lubanovic', 'Zamanialaei', 'Fain', 'McCarty'),
                        length(srsamp))) %>%
  ungroup()

#

#  ----
lut <- read_csv('/Volumes/Yggdrasil/Projects/AMAP/Data/em_ef2.csv') %>%
  select(Code1, IGBP_Name) %>%
  mutate(Code1 = as.character(Code1))


assigned_alcs_named <- left_join(assigned_alcs, lut, by = c('IGBP' = 'Code1'))

assigned_alcs_named <- assigned_alcs_named %>% select(!Area)
#

#  ----

filter(assigned_alcs_named, Tech == 'Cabrera') %>%
  as_Spatial() %>%
  writeOGR(here('Outs', 'pixel_polys', 'Africa_LC_sample_Cabrera.shp'), 'LC_Poly', driver = 'ESRI Shapefile')

filter(assigned_alcs_named, Tech == 'Somers') %>%
  as_Spatial() %>%
  writeOGR(here('Outs', 'pixel_polys', 'Africa_LC_sample_Somers.shp'), 'LC_Poly', driver = 'ESRI Shapefile')

filter(assigned_alcs_named, Tech == 'Lubanovic') %>%
  as_Spatial() %>%
  writeOGR(here('Outs', 'pixel_polys', 'Africa_LC_sample_Lubanovic.shp'), 'LC_Poly', driver = 'ESRI Shapefile')

filter(assigned_alcs_named, Tech == 'Zamanialaei') %>%
  as_Spatial() %>%
  writeOGR(here('Outs', 'pixel_polys', 'Africa_LC_sample_Zamanialaei.shp'), 'LC_Poly', driver = 'ESRI Shapefile')

filter(assigned_alcs_named, Tech == 'McCarty') %>%
  as_Spatial() %>%
  writeOGR(here('Outs', 'pixel_polys', 'Africa_LC_sample_McCarty.shp'), 'LC_Poly', driver = 'ESRI Shapefile')

filter(assigned_alcs_named, Tech == 'Fain') %>%
  as_Spatial() %>%
  writeOGR(here('Outs', 'pixel_polys', 'Africa_LC_sample_Fain.shp'), 'LC_Poly', driver = 'ESRI Shapefile')

#