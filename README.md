### Description

This project generates a poster-sized information “dashboard” visualization about my road trips.  The dashboard includes a map of my travels and travel destination goals, a progress bar of destinations I have visited, and a mini-map of the routes I intend to drive to accomplish my goals.  I track my travels and destinations in Google Earth; this project reads in KML files exported from it.

Central to this project is a list of 111 destination cities in the United States and Canada.  To generate the United States list, I wrote a separate script to divide US metropolitan areas (henceforth “cities”) into geographic areas (via Ward’s minimum distance hierarchical clustering).  Within each area, the script identified the most populous city in each area, all cities with more than a million residents, and any city settled before 1650.  These cities served as the initial contenders to be destination sites for that area. If this amounted to more than two contenders in an area, I manually determined if there were some cities that I was willing to strike from the list.  The Canadian list follows a similar logic.  It consists of the largest city in each province that borders the contiguous United States, plus every city with a population greater than one million.  However, I skimped on sites in Newfoundland, New Brunswick, and Nova Scotia for practical reasons -- Canada is quite large and the US is the central focus of my road trip goals, so I had to draw the line somewhere.

### Repository Layout

This repository contains 3-4 directories.  For convenience, each directory name has a unique letter prefix, such as "X_".

+ **A_Inputs** - Holds all source data files.  For coding purposes, I treat this directory as read only.
+ **B_Intermediates** – Holds data files created as byproducts of the computations performed.  This can include cached API pulls, temporary data caches for large computations, and data objects to be passed from one script to the next.
+ **C_Outputs** – Holds the final products for the project.
+ **D_Misc** – If needed, this directory will contain any other useful materials for the project, such as source data documentation.

The scripts containing executable code are in the top level of the repository. Each script has a unique numeric prefix, such as "2_", which indicates the order in which to execute the scripts.

### Scripts (Actions, Inputs, and Outputs)

This section describes the executable scripts that comprise this project.

**1_data_shaping.R** – Processes KML files describing my road trips and road trip goals.  Combines dataset with built-in map data on the geographies involved, projects all coordinates, and packages the data into a standardized long dataset.

Inputs (from A_Inputs):
+ Travels.kml - Records the cities and routes traveled on my road trips so far.
+ Wishlist.kml - Describes the cities I aspire to visit (without regard to which have been visited already or not), and the standardized routes I intend to follow to visit them.
+ Map data drawn from the previously installed package::maps

Outputs (to B_Intermediates):
+ progress.RData - A small tabulation table of the cities / states that I have visited / aspire to visit.
+ travels.RData - A long dataset of coordinate data for all the polygons needed to describe the geographic borders, road trip routes, and cities involved in my road trips.

**2_render_map.R** – Renders a poster-sized information "dashboard" about my road trips and road trip goals.

Inputs (from B_Intermediates): progress.RData and travels.Rdata, as described under script #1.

Outputs (to C_Outputs):
+ road_trip_poster.pdf - PDF dashboard visualization of my road trips and road trip plans.  Sized to fit a 3 ft x 2 ft poster.
+ road_trips.png -  Smaller PNG version of the same visualization, designed to load easier for quick inspection.  Provides the thumbnail for this project in the project gallery (https://sjoshuam.github.io/project_gallery/).

### Project Status and To-Dos

This project is nearly done and mostly requires polishing at this point.  As I travel and / or adjust my goals, I will periodically upload updated KML files and regenerate the dashboard.

- [ ] Make sure the poster, README, and gallery text are fully aligned.

- [ ] Proof-read and improve the text on the poster, gallery text, and this README file.

- [ ] Print poster and pin to my wall!
