##########==========##########==========##########==========##########==========

## SET-UP ======================================================================

## meta-information
## author: Josh Mendelsohn
## creation: 2021-01-24
## version: R 4.0.3
## description: renders maps of road trips and road trip goals

## environment set up
remove(list = objects())
options(scipen = 2, digits = 6)
#library(lintr) #lint("2_render_map.R")
library(readxl)
library(tidyverse)

refresh_pdf <- FALSE

## READ IN DATA ================================================================

## read in files
travels  <- readRDS("B_Intermediates/travels.RData")
progress <- readRDS("B_Intermediates/progress.RData")
poster_dims <- read_xlsx("A_Inputs/poster_dims.xlsx")

## expression raw progress statistics
wished_cities <- progress %>% filter(theme == "Wishlist") %>% pull("city")
progress

wished_routes <- travels %>%
  filter(theme == 'Wishlist', polygon == 'LineString') %>%
  pull(level1) %>%
  unique %>%
  length

travels %>%
  filter(theme == 'Wishlist', polygon == 'LineString') %>%
  pull(level1) %>%
  unique

## PREPARE FOUNDATIONAL PLOT DATA ==============================================

## convert master dimension dataset to non-tibble format (for easier lookups)
poster_dims <- as.data.frame(poster_dims)
rownames(poster_dims) <- poster_dims$element
poster_dims$elements <- NULL

## define master size scalar for map scale elements
master_size <- 25.4 * 0.05

## initialize ggplot object
travel_poster <- ggplot(size = 25.4*0.1) +
  coord_fixed(xlim= c(0, 36), ylim = c(0, 24), expand = FALSE, ratio = 1)

## patch bug where polygon designators are not unique
warning("TODO: hunt down source of bug in script #1")

travels <- travels %>%
  mutate(group = as.numeric(as.factor(paste(level1, group))))

## PREPARE TO RENDER MAP PANELS ================================================

## rescale coordinates to unity
travels$x <- travels$x - min(travels$x)
travels$y <- travels$y - min(travels$y)
scale_factor <- 1 / max(c(travels$x, travels$y))
travels[, c("x", "y")] <- travels[, c("x", "y")] * scale_factor
remove(scale_factor)

## calculate coordinates for each plot panel (leaving a little room for titles)
traveled_routes <- standard_routes <- travels[, c("x", "y")]
traveled_routes$x <- (traveled_routes$x * poster_dims["travels_inset", "x_size"]
  ) + poster_dims["travels_inset", "x_start"]
traveled_routes$y <- (traveled_routes$y * poster_dims["travels_inset", "x_size"]
  ) + poster_dims["travels_inset", "y_start"]
standard_routes$x <- (standard_routes$x * poster_dims["routes_inset", "x_size"]
  ) + poster_dims["routes_inset", "x_start"]
standard_routes$y <- (standard_routes$y * poster_dims["routes_inset", "x_size"]
  ) + poster_dims["routes_inset", "y_start"]

colnames(traveled_routes) <- paste0("traveled_", colnames(traveled_routes) )
colnames(standard_routes) <- paste0("standard_", colnames(standard_routes) )
travels <- bind_cols(travels, traveled_routes, standard_routes)
remove(traveled_routes, standard_routes)

## categorize cities by visited / not visited
travels <- mutate(travels,
  "been_there" = travels$level1 %in% travels$level1[travels$theme == "Travels"]
  ) %>%
#  mutate("been_there" = if_else(been_there, "Visited", "Not Visited")) %>%
  mutate(
    "been_there" = if_else(polygon == "Point", been_there, as.logical(NA)))

## categorize cities by closest standard route
cities <- travels %>%
  filter(polygon == "Point", theme == "Wishlist") %>%
  select(level1, x, y)
routes <- filter(travels, polygon == "LineString", theme == "Wishlist") %>%
  select(level1, x, y)

city_route_dist <- outer(cities$x, routes$x, FUN = "-")^2
city_route_dist <- city_route_dist + outer(cities$y, routes$y, FUN = "-")^2
city_route_dist <- apply(city_route_dist, 1, which.min)
city_route_dist <- routes$level1[city_route_dist]
city_route_dist <- tibble(
  "City" = cities$level1,
  "route_of_city" = city_route_dist) %>%
  mutate(
    "route_of_city" = if_else(
      City %in% c("San Juan PR", "Honolulu HI"),
      "Not Currently On A Route", route_of_city)
    )
travels <- left_join(travels, city_route_dist, by = c("level1" = "City"))
remove(city_route_dist)

## generate color palette
color_palette <- tribble(
  ~name, ~hue,
  "land", 0.10,
  "sea",  0.60,
  )
color_palette$light  <- hsv(color_palette$hue, 0.1, v= 1.0)
color_palette$medium <- hsv(color_palette$hue, 0.8, v= 0.7)
color_palette$dark   <- hsv(color_palette$hue, 1.0, v= 0.4)

grab_color <- function(color_name, color_type, dat = color_palette) {
  pull(dat[dat$name == color_name,], color_type)
}

## PANEL 1: LEGEND =============================================================
## generate legend text dataset
legend_data <- travels %>%
  filter(theme == "Wishlist", polygon == "LineString") %>%
  distinct(level1) %>%
  mutate(legend = "Preplanned Routes") %>%
  add_row(
    "level1" = c("Have Visited", "Intend To Visit", "Not Currently On A Route"),
    "legend" = c(rep("Travels So Far", 2), "Preplanned Routes")
    ) %>%
  mutate("type" = "item") %>%
  add_row(
    "type" = "title",
    "legend" = c("Travels So Far", "Preplanned Routes"),
    "level1" = c("Key: Travels So Far ", "Key: Preplanned Routes")
    ) %>%
  select(legend, type, level1) %>%
  arrange(desc(legend), desc(type))


## calculate coordinates
legend_data$x <- poster_dims["key_inset", "x_start"] +
  if_else(legend_data$type == "title", 0, 1.0)
  
legend_y <- seq(
  from = poster_dims["key_title", "y_end"],
  to = mean(unlist(poster_dims["key_inset", c("y_start", "y_end")])),
  length.out = nrow(legend_data) + 2
  )
legend_y <- legend_y[c(-1, -length(legend_y))]
legend_data$y <- if_else(legend_data$legend == "Preplanned Routes",
  legend_y - 0.2, legend_y)
remove(legend_y)

## add color data
legend_data$fill <- legend_data$color <- grab_color("sea", "dark")

i <- (legend_data$legend == "Preplanned Routes") & (
  legend_data$type == 'item')
legend_data$fill[i] <- hcl(
  h = seq(from = 0, to = 360, length.out = sum(as.numeric(i))),
  c = 100,
  l = 40
  )

i <- legend_data$level1 == "Intend To Visit"
legend_data[i, "color"] <- grab_color("land", "dark")
legend_data[i, "fill"] <- grab_color("land", "light")
legend_data[!i, "color"] <- legend_data[!i, "fill"]

i <- legend_data$type == "title"
legend_data[i, "color"] <- legend_data[i, "fill"] <- "transparent"

remove(i)

## Gray out points that are not currently on a route
i <- str_detect(legend_data$level1, "Not Currently")
legend_data[i, "color"] <- legend_data[i, "fill"] <- "gray50"

## render legend text
travel_poster <- travel_poster +
  geom_text(
    data = legend_data,
    mapping = aes(x = x, y = y, label = level1),
    fontface = "bold", hjust = 0,
    size = if_else(legend_data$type == "title", 12, 7),
    color = grab_color("sea", "dark"),
    vjust = 0
    )

## render legend color dots
travel_poster <- travel_poster +
  geom_point(
    data = legend_data,
    mapping = aes(x = x - 0.5, y = y + 0.1),
    color = legend_data$color, fill = legend_data$fill,
    size = if_else(legend_data$type == "title", 0, master_size * 5),
    shape = 21, stroke = master_size * 2
    )

## render explanatory text
explanatory_text <- c(
  "This poster depicts information about my travels",
  "",
  "The \"Trips So Far\" panel maps where I have traveled so far, as well ",
  "as the other places I strive to visit. Taken together, I aim ",
  "to see ", wished_cities,
  " metropolitan areas across the US and adjacent areas of Canada. ",
  "The \"Preplanned Routes\"  panel outlines ",
  wished_routes, " travel plans. ",
  " Together, those routes pass through ",
  wished_cities - 2, " of the ", wished_cities, " ",
  "metropolitan areas.  The \"Progress\" panel shows my progress visiting all ",
  "areas. ",
  "For each city visited, I walk a 5+ mile route through ",
  "the core city, striving to see downtowns, historic districts, and other ",
  "noteworthy sites.",
  "",
  "To choose these cities, I considered criteria that included population ",
  "size, local primacy, state capitals, and cities in proximity to sites of ",
  "natural / cultural / historical ",
  'significance.  Then, I used hiearchical cluster analysis to divide finalists ',
  "into travel routes, minimizing the mileage necessary to ",
  "see them. The legend lists the routes in order of how much they would ",
  "contribute to my goal of visiting every city and state.",
  "",
  "The R code underlying this visualization is publicly available on GitHub at: ",
  "https://github.com/sjoshuam/road_trips"
    )
explanatory_text <- tapply(explanatory_text, cumsum(!nzchar(explanatory_text)),
  paste, collapse = "") %>%
  str_wrap(width = 78) %>%
  paste(collapse = "\n\n")


travel_poster <- travel_poster +
  geom_text(
    data = filter(poster_dims, str_detect(element, "key_inset")),
  mapping = aes(x = x_start, y = y_start),
  label = explanatory_text, fontface = "bold",
  size = 7, hjust = 0, vjust = 0, color = grab_color("sea", "dark")
  )
remove(explanatory_text)

## PANEL 4: ROUTES TRAVELED ====================================================

## generate blank state map
states <- travels %>%
  filter(polygon == "Polygon", theme == "map") %>%
  select(level1, group, traveled_x, traveled_y)
travel_poster <- travel_poster + geom_polygon(
  data = states,
  mapping = aes(x = traveled_x, y = traveled_y, group = group),
  color = grab_color("land", "dark"),
  fill = grab_color("land", "light"),
  size = master_size
  )
remove(states)

## generate routes
routes <- travels %>%
  filter(theme == "Travels", polygon == "LineString") %>%
  select(group, traveled_x, traveled_y)
travel_poster <- travel_poster + geom_path(data = routes,
  mapping = aes(x = traveled_x, y = traveled_y, group = group),
  color = grab_color("land", "light"),
  size = master_size * 3.0
  )
travel_poster <- travel_poster + geom_path(data = routes,
  mapping = aes(x = traveled_x, y = traveled_y, group = group),
  color = grab_color("sea", "medium"),
  size = master_size *1.5
  )
remove(routes)

## render cities
cities <- travels %>%
  filter(theme == "Wishlist", polygon == "Point") %>%
  select(been_there, traveled_x, traveled_y)
travel_poster <- travel_poster + geom_point(data = cities,
  mapping = aes(x = traveled_x, y = traveled_y),
  size = master_size * ifelse(cities$been_there, 6, 4),
  stroke = master_size * 2,
  color = ifelse(
   cities$been_there, grab_color("land", "light"), grab_color("land", "dark")),
  fill = ifelse(
   cities$been_there, grab_color("sea", "dark"), grab_color("land", "light")),
  shape = 21
  )
remove(cities)

## render traveled routes panel title
travel_poster <- travel_poster + geom_text(
  data = filter(poster_dims, str_detect(element, "travels_title")),
  mapping = aes(
    x = (x_start + x_end) / 2,
    y = (y_start + y_end) / 2,
    ),
  label = "Travels So Far",
  color = grab_color("sea", "dark"),
  size = 24, fontface = "bold", vjust= 0
  )

## PANEL 3: STANDARD ROUTES ====================================================

## render states
states <- travels %>%
  filter(polygon == "Polygon", theme == "map") %>%
  select(group, standard_x, standard_y)
travel_poster <- travel_poster + geom_polygon(
    data = states,
    mapping = aes(x = standard_x, y = standard_y, group = group),
    color = grab_color("land", "dark"),
    fill = grab_color("land", "light"),
    size = master_size
  )
remove(states)

## render routes
routes <- travels %>%
  filter(theme == "Wishlist", polygon == "LineString") %>%
  select(level1, group, standard_x, standard_y)
travel_poster <- travel_poster +
  geom_path(data = routes,
    mapping = aes(x = standard_x, y = standard_y, group = group),
    size = master_size * 3,
    color = grab_color("land", "light")) +
  geom_path(data = routes,
    mapping = aes(x = standard_x, y = standard_y, group = group, color = level1),
    size = master_size) +
  scale_color_manual(values = set_names(legend_data$color, legend_data$level1))
remove(routes)

## render cities
cities <- travels %>%
  filter(theme == "Wishlist", polygon == "Point") %>%
  select(route_of_city, standard_x, standard_y)
travel_poster <- travel_poster + geom_point(data = cities,
  mapping = aes(x = standard_x, y = standard_y),
  size = master_size * 4, color = grab_color("land", "light")
  ) + geom_point(data = cities,
  mapping = aes(x = standard_x, y = standard_y, color = route_of_city),
  size = master_size * 3
  )
remove(cities)

## render inset panel title
travel_poster <- travel_poster +
  geom_text(
    data = filter(poster_dims, str_detect(element, "routes_title")),
  mapping = aes(
    x = (x_start + x_end) / 2,
    y = (y_start + y_end) / 2,
    ),
  label = "Preplanned Routes",
  color = grab_color("sea", "dark"),
  size = 18, fontface = "bold", vjust= 0
  )

## PANEL 2: PROGRESS BAR =======================================================

## convert progress data to non-tibble format (for easier look-ups) 
progress <- add_row(
  progress,
  tibble("theme" = c("Percent", "Bars"), "state" = rep(NA, 2),
    "city" = rep(NA, 2))
  ) %>%
  as.data.frame()

rownames(progress) <- progress$theme
progress$theme <- NULL

## calculate percentage and 25-bar equivalent
progress["Percent", ] <- progress["Travels", ] / progress["Wishlist", ]
progress["Bars", ] <- floor(progress["Percent", ] * 25)

## generate progress bar coordinates
progress_x <- seq(
  from = poster_dims["progress_inset", "x_start"] + 4.2,
  to = poster_dims["progress_inset", "x_end"] - 2,
  length.out = 26)
progress_y <- seq(
  from = poster_dims["progress_inset", "y_start"],
  to = poster_dims["progress_inset", "y_end"],
  length.out = 6
  )

progress_bars <- tibble(
  "xmin" = progress_x[-26],
  "xmax" = progress_x[-1] - 0.2,
  "ymin_state" = progress_y[5],
  "ymax_state" = progress_y[4],
  "ymin_city" = progress_y[2],
  "ymax_city" = progress_y[3],
  "progress_state" = FALSE,
  "progress_city" = FALSE
  )

progress_bars$progress_state[seq(progress["Bars", "state"])] <- TRUE
progress_bars$progress_city[seq(progress["Bars", "city"])] <- TRUE

remove(progress_x, progress_y)

## render bars
travel_poster <- travel_poster + geom_rect(
  data = progress_bars,
  mapping = aes(
    xmin = xmin,
    xmax = xmax,
    ymin = ymin_state,
    ymax = ymax_state
    ),
    fill = if_else(
      progress_bars$progress_state,
      grab_color("sea", "dark"), grab_color("sea", "medium")),
    color = grab_color("sea", "dark"),
  size = 2
  ) + geom_rect(
  data = progress_bars,
  mapping = aes(
    xmin = xmin,
    xmax = xmax,
    ymin = ymin_city,
    ymax = ymax_city
    ),
    fill = if_else(
      progress_bars$progress_city,
      grab_color("sea", "dark"), grab_color("sea", "medium")),
    color = grab_color("sea", "dark"),
    size = 2
  )

## render bar labels
travel_poster <- travel_poster + geom_text(
    data = tibble(NA),
    x = min(progress_bars$xmin) - 0.4,
    y = unique(progress_bars$ymin_state + progress_bars$ymax_state) / 2, 
    label = "States (And\nEquiv.) Visited:",
    color = grab_color("sea", "dark"),
    hjust = 1, fontface = "bold", size = 12
  ) + geom_text(
    data = tibble(NA),
    x = min(progress_bars$xmin) - 0.4,
    y = unique(progress_bars$ymin_city + progress_bars$ymax_city) / 2,
    label = "Metropolitan\nAreas Visited:",
    color = grab_color("sea", "dark"),
    hjust = 1, fontface = "bold", size = 12
  ) + geom_text(
    data = tibble(NA),
    x = max(progress_bars$xmax) + 0.4,
    y = unique(progress_bars$ymin_state + progress_bars$ymax_state) / 2,
    label = paste0(round(progress["Percent", "state"] * 100), "%"),
    color = grab_color("sea", "dark"),
    hjust = 0, fontface = "bold", size = 20, vjust = 0.5
  ) + geom_text(
    data = tibble(NA),
    x = max(progress_bars$xmax) + 0.4,
    y = unique(progress_bars$ymin_city + progress_bars$ymax_city) / 2,
    label = paste0(round(progress["Percent", "city"] * 100), "%"),
    color = grab_color("sea", "dark"),
    hjust = 0, fontface = "bold", size = 20, vjust = 0.5
  ) + geom_text(
    data = filter(poster_dims, str_detect(element, "progress_title")),
    mapping = aes(
      x = (x_start + x_end) / 2,
      y = (y_start + y_end) / 2
      ),
    label = "Progress Towards Visiting Listed US / Canadian Metropolitan Areas",
    color = grab_color("sea", "dark"),
    hjust = 0.5, fontface = "bold", size = 18, vjust = 0
  )
remove(progress_bars)


## MAP STYLING =================================================================

## render panel dividers and remove automatic legend
travel_poster <- travel_poster +
  geom_segment(
    data = filter(poster_dims, str_detect(element, "vertical_divider")),
    mapping = aes(
      x = (x_start + x_end) / 2,
      xend = (x_start + x_end) / 2,
      y = y_start, yend = y_end
        ),
    color = grab_color("sea", "dark"), size= 2
    ) +
  geom_segment(
    data = filter(poster_dims, str_detect(element, "horizontal_divider")),
    mapping = aes(
      x = x_start, xend = x_end,
      y = (y_start + y_end) / 2,
      yend = (y_start + y_end) / 2
        ),
    color = grab_color("sea", "dark"), size= 2
    ) + theme(
    plot.margin = unit(rep(0, 4), units = "in"),
    axis.text = element_blank(), axis.line = element_blank(),
    axis.ticks = element_blank(), axis.title = element_blank(),
    panel.background = element_rect(fill = grab_color("sea", "light")),
    panel.grid = element_blank(), panel.border = element_blank(),
    legend.position = "none"
    )

## EXPORT TO PDF ===============================================================

png("C_Outputs/us_travels.png",
  width = 36,
  height = 24,
  units = "in",
  res = 150)
travel_poster
graphics.off()


pdf("C_Outputs/us_travels_poster.pdf", width = 36, height = 24)
travel_poster
graphics.off()

##########==========##########==========##########==========##########==========
