# Overview
This project renders a 'dashboard' visualization of information about my travels
in the United States and adjacent areas of Canada. I have written many versions
of this dashboard over the years.  This one incorporates UX insights from how I
used the last one.  It will be the first one written in Python, instead of R.
However, I may make an R translation after I complete the Python version.

# Task Board
See Z_Admin/dashboard_plan.pptx for basic sketch of the dashboard.  Current task list:

|                     |Skeleton |Tests |Functions |Evolution |Score           |
|:--------------------|:----    |:---- |:----     |:----     |:----
|
**General Elements**
|process_layout       |X        |X     |          |          |3 x 1.2% = 2.4% |
|display_layout       |X        |X     |          |          |2 x 2.4% = 2.4% |
|process_map          |         |      |          |          |0 x 1.2% = 0.0% |
|display_map          |         |      |          |          |0 x 1.2% = 0.0% |
|define_style         |         |      |          |          |0 x 1.2% = 0.0% |
|
**Panel Elements (Simple)**
|process_explanation  |X        |      |          |          |1 x 1.2% = 1.2% |
|display_explanation  |X        |      |          |          |1 x 1.2% = 1.2% |
|process_progress     |         |      |          |          |0 x 1.2% = 0.0% |
|display_progress     |         |      |          |          |0 x 1.2% = 0.0% |
|process_legend_plus  |         |      |          |          |0 x 1.2% = 0.0% |
|display_legend_plus  |         |      |          |          |0 x 1.2% = 0.0% |
|
**Panel Elements (Maps)**
|process_routes       |         |      |          |          |0 x 1.2% = 0.0% |
|display_routes       |         |      |          |          |0 x 1.2% = 0.0% |
|process_opportunity  |         |      |          |          |0 x 1.2% = 0.0% |
|display_opportunity  |         |      |          |          |0 x 1.2% = 0.0% |
|process_travels      |         |      |          |          |0 x 1.2% = 0.0% |
|display_travels      |         |      |          |          |0 x 1.2% = 0.0% |
|
**Total Progress**
|Planning             |         |      |          |          |10.0% of  10.0% |
|Coding               |         |      |          |          |07.2% of  81.6% |
|Buffer               |         |      |          |          |00.0% of  08.4% |
|Buffer               |         |      |          |          |17.2% of 100.4% |

# Task Description

**General Elements**
+ **process_layout** - do computations for a 6-panel dashboard visualization
dashboard layout
  + **display_layout** - display the 6-panel dashboard layout
+ **process_map** - do computations for a background map of us states.
  + **display_map** - display the background map
  + *Background maps shows us state borders and will sit under other geographic
    visualizations.  May have insets for AK, HI, PR, depending on the difficulty
    involved.*
+ **define_style** - customize plot style elements

**Panel Elements (Simple)**
+ **process_explanation** - do computations for the explanatory text panel
  + **display_explanation** - display explanatory panel
  + *Panel tells the basic story of the project*
+ **process_progress** - do computations for progress bar chart panel
  + **display_progress** - display explanatory panel
  + *Horizontal bar chart panels measures progress towards seeing all states
    and cities*
+ **process_legend_plus** - do computations for table of useful information
  about the planned routes, including color legend for planned routes
  + **display_legend_plus** - display legend+ table
  + *Table / legend hybrid presents information about the planned routes*

**Panel Elements (Maps)**
+ **process_routes** - do computations for planned routes map
  + **display_routes** - display planned routes map
  + *Panel superimposes planned travel routes on the background map*
+ **process_opportunity** - do computations for opportunity score map
  + **display_opportunity** - display opportunity score map
  + *Panel superimposes a kernel density heat map (plasma color scale) on the
    background map*
+ **process_travels** - do computations for map of past travels
  + **display_travels** - display map of past travels
  + *Panel superimposes past travel routes on the background map*

# Directory Layout
Project directories are lettered to indicate sequences, and code scripts are
numbered for the same reason.
+ A_Input - Original input data.  Should be read but never written.
+ B_Progress - Contains intermediate data as needed.  Generally, these files
facilitate data hand-offs between scripts.
+ C_Output - Tables and visualizations that are the project's final products.
+ Z_Admin - Documentation as needed to provide guidance and context for the
project. Most significantly, this directory contains any supplemental planning material.
