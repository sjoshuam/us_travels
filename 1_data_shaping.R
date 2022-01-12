##########==========##########==========##########==========##########==========

## SET-UP ======================================================================

## meta-information
## Author: Joshua Mendelsohn
## Creation: 2021-01-17
## Version: 4.0.3
## Description: Shape and merge road trip and map data

##  environment set-up
remove(list = objects())
options(digits = 6, scipen = 2)
library(xml2)
library(tidyverse)
library(mapproj)


## READ IN DATA ================================================================

travels <- read_xml("A_Inputs/Travels.kml")
wishlist <- read_xml("A_Inputs/Wishlist.kml")

oconus_map <- as_tibble(map_data("world",
  region = c("USA:Alaska", "USA:Hawaii", "Puerto Rico")))
conus_map <- as_tibble(map_data("state"))

## CLEAN AND COMPILE MAP DATA ==================================================

## merge maps and harmonize state coding
us_map <- bind_rows(conus_map, oconus_map) %>%
  mutate("region" = ifelse(region == "USA", subregion, region))
remove(oconus_map, conus_map)

## convert state names with postal codes
postal_codes <- match(
  str_to_title(us_map$region),
  c(state.name, "Puerto Rico", "District Of Columbia"))
postal_codes <- c(state.abb, "PR", "DC")[postal_codes]
us_map <- mutate(us_map, "state" = postal_codes)
remove(postal_codes)

## drop specific islands to improve map aesthetics
us_map <- filter(us_map,
  !((state == "AK") & (group != 78)),
  !((state == "WA") & (group != 60))
  )

## CLEAN AND COMPILE KML CITY DATA =============================================

## write recursive function to extract object names from kml hierarchy
name_extractor <- function(kml_list) {
  if (!is.list(kml_list) | is.null(names(kml_list))) {
    return(kml_list)
  } else{
    i <- any(names(kml_list) %in% c("Folder", "Placemark"))
    j <- sapply(kml_list, function(x) {unlist(x$name)})
    names(kml_list)[i] <- paste(names(kml_list)[i], j, sep = "∆")
    lapply(kml_list, name_extractor)
      }
  }

## convert kml files to a tidy-esque format
travels  <- travels  %>% as_list() %>% name_extractor %>% unlist() %>% enframe()
wishlist <- wishlist %>% as_list() %>% name_extractor %>% unlist() %>% enframe()


remove(name_extractor)
## merge travel and wishlist files
travels$name  <- paste("travels",  travels$name, sep = ".")
wishlist$name <- paste("wishlist", wishlist$name, sep = ".")
travels <- bind_rows(travels, wishlist)
remove(wishlist)

## extract and refine coordinate data
refine_coordinates <- function(raw_xy) {
  raw_xy <- raw_xy %>%
    str_remove_all("[\t\n]") %>%
    trimws() %>%
    str_split(" +") %>%
    lapply(str_split, ",") %>%
    rapply(as.numeric, how = "list") %>%
    lapply(simplify2array) %>%
    lapply(t)

  raw_xy
  }

travels <- travels %>%
  filter(
    str_detect(name, "coordinates"),
    !str_detect(name, "Folder∆Walks"),
    !str_detect(name, "Folder∆Alternates"),
    !str_detect(name, "Folder∆Labels")
    ) %>%
  mutate("value" = refine_coordinates(value)) %>%
  unnest(value)

remove(refine_coordinates)

## parse kml hierarchy
temp <- travels$name %>%
  str_split("[.]") %>%
  simplify2array() #%>%
  #t()

travels$name <- travels$name %>%
  str_split("[.]") %>%
  simplify2array() %>%
  t()

## flatten refined data
travels <- cbind(travels$name, travels$value)
travels <- as_tibble(travels)

colnames(travels) <- c(
  "file", "format", "header",
  "folder1", "folder2", "folder3",
  "placemark", "polygon", "data_type",
  "long", "lat", "altitude"
  )

## get rid of excess directory levels
i <- sapply(travels, function(x) {length(unique(x))})
i <- names(i[i > 1])
travels <- travels[, i] %>% select(-altitude, -file)
remove(i)

## convert coordinates to numeric
travels$long <- as.numeric(travels$long)
travels$lat <- as.numeric(travels$lat)

## simplify directory structure
travels[, c("folder1", "folder2", "folder3")] <- apply(
  travels[, c("folder1", "folder2", "folder3")],
  2,
  str_remove_all,
  pattern = "Folder∆"
  )

travels$placemark <- str_remove_all(travels$placemark, "Placemark∆")

## STANDARDIZE FORMATS =========================================================

## generate polygon groups and orders for travels
travels <- travels %>% mutate(
  "group" = paste(folder1, folder2, folder3, placemark),
  "order" = seq(nrow(travels))
  )
travels$group <- travels$group %>%
  factor(levels = unique(travels$group)) %>%
  as.numeric()
travels$order <- 1 + travels$order - tapply(
  travels$order, travels$group, min)[as.character(travels$group)]

## generate states for polygons
travels$state <- travels$placemark %>%
  str_extract_all(" [A-Z][A-Z][A-Z]*") %>%
  lapply(unique) %>%
  lapply(sort) %>%
  sapply(paste, collapse = "/") %>%
  str_remove_all(" ")

## stanardize organizational schemes
us_map$theme <- "map"
travels$theme <- travels$folder1

us_map$polygon <- "Polygon"

us_map$level1 <- us_map$state
travels$level1 <- if_else(
  travels$polygon == "LineString",
  travels$folder3,
  travels$placemark
  )
travels$level2 <- if_else(
  travels$polygon == "LineString",
  travels$placemark,
  as.character(NA)
  )
us_map$level2 <- NA

us_map <- select(us_map, long, lat, group, order,
  theme, state, level1, level2, polygon)
travels <- select(travels, long, lat, group, order,
  theme, state, level1, level2, polygon)

## remove travel marks outside project bounds
travels <- filter(travels, !str_detect(travels$level1, ", [A-Z][a-z]+"))

## merge data
travels <- bind_rows(travels, us_map)
remove(us_map)

## HARMONIZE CITY DATA =========================================================

harmony <- travels %>%
  filter(polygon == "Point") %>%
  group_by(level1) %>%
  summarize(
    "long_mean" = mean(long),
    "lat_mean"  = mean(lat)
    )

travels <- travels %>%
  left_join(harmony, by = "level1") %>%
  mutate(
    lat  = if_else(polygon == "Point", lat_mean,  lat),
    long = if_else(polygon == "Point", long_mean, long),
    ) %>%
  select(-lat_mean, -long_mean)
remove(harmony)

## PROJECT COORDINATES =====================================

## flatten routes/cities that are too far north
i <- travels$state == "CAN" & travels$lat > 52.2
travels[i, "lat"] <- 52.2

## write tidy/pipe-esque projection function
tidy_projection <- function(dat, filt, proj, orient, param = NULL) {
  coordinates <- dat %>% filter(filt) %>% select(long, lat)
  coordinates <- mapproject(
    x = coordinates$long, y = coordinates$lat,
    projection = proj, orientation = orient, parameters = param
    )
  dat[filt, "x"] <- coordinates$x
  dat[filt, "y"] <- coordinates$y
  dat
  }

## project coordinates
travels <- travels %>%
  mutate("x" = as.numeric(NA), "y" = as.numeric(NA)) %>%
  tidy_projection(filt = !(travels$state %in% c("AK", "HI", "PR")),
    proj = "lambert", orient = c(90, 0, -98.6), param = c(25.1, 49.4)) %>%
  tidy_projection(filt = travels$state == "AK",
    proj = "lambert", orient = c(90, 0, -152.5), param = c(54.8, 71.4)) %>%
  tidy_projection(filt = travels$state == "HI",
    proj = "mercator", orient = c(90, 0, -156.7)) %>%
  tidy_projection(filt = travels$state == "PR",
    proj = "mercator", orient = c(90, 0, -66.4))

## scale alaska
scale_down <- function(coordinate, size_factor = 0.5) {
  result <- coordinate - mean(coordinate)
  result * size_factor + mean(coordinate)
}
travels <- travels %>%
  mutate(x = if_else(state == "AK", scale_down(x, 0.25), x),
    y = if_else(state == "AK", scale_down(y, 0.25), y)) %>%
  mutate(x = if_else(state %in% c("HI", "PR"), scale_down(x, 0.5), x),
    y = if_else(state %in% c("HI", "PR"), scale_down(y, 0.5), y))

## position OCONUS
reposition_state <- function(dat, moving_state, ref_state, nudge = c(0, 0)) {

  ## calculate how must to adjust state coordinates
  adjustments <- dat %>%
    filter(state %in% c(moving_state, ref_state)) %>%
    select(state, x, y) %>%
    group_by("moving" = state == moving_state) %>%
    summarize(x_adj = min(x), y_adj = min(y))
  adjustments <- as_vector(adjustments[1, 2:3] - adjustments[2, 2:3])

  ## adjust state coordinates
  dat <- mutate(dat,
    x = if_else(state == moving_state, x + adjustments[1] + nudge[1], x),
    y = if_else(state == moving_state, y + adjustments[2] + nudge[2], y),
    )
  dat

  }

travels <- travels %>%
  reposition_state("AK", c("CA", "TX")) %>%
  reposition_state("HI", c("UT", "TX")) %>%
  reposition_state("PR", c("NE", "FL"), c(-0.015, -0.005))

## TABULATE PROGRESS STATISTICS ================================================
unique_count <- function(x) {
  length(unique(na.omit(x)))
  }

progress <- travels %>%
  filter(polygon == "Point",
    level1 %in% travels$level1[travels$theme == "Wishlist"]) %>%
  select(state, level1, theme) %>%
  mutate(state = recode(state, CAN = as.character(NA))) %>%
  group_by(theme) %>%
  summarize(
    "state" = unique_count(state),
    "city"  = unique_count(level1)
    )

## EXPORT DATA =================================================================

saveRDS(travels, file = "B_Intermediates/travels.RData")
saveRDS(progress, file = "B_Intermediates/progress.RData")

##########==========##########==========##########==========##########==========
