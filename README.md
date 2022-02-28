# Overview
This project renders a 'dashboard' visualization of information about my travels
in the United States and adjacent areas of Canada. I have written many versions
of this dashboard over the years.  This one incorporates UX insights from how I
used the last one.  It will be the first one written in Python, instead of R.
However, I may make an R translation after I complete the Python version.

# Task Board
See Z_Admin/dashboard_plan.pptx for basic sketch of the dashboard.

I have divided this project into a series of functions (the rows in the table
below) and phases (the columns).  The functions are described below the table.
The phases are:
+ i0 - Build just enough code to prove that the architecture is viable and
confirm assumptions about the flow of code.  Use placeholder text/data/functions
 to accelerate this phase.
+ T - Develop tests to confirm that each function does what it should do.
This ensures that an automated test suite validates the codes before each
deployment and warns when code regression has occurred.
+ i1 - Replace all placeholder code with functional code and ensure that
all functions passed automated tests.
+ i2 - Analyze code in light of the whole script, and analyze performance
in light of time/resource codes.  Evolve the code.

|                     |i0  |T   |i1  |i2  |Total |
|:--------------------|:-- |:-- |:-- |:-- |:---- |
|                     |    |    |    |    |      |
**General Elements**
|process_layout       |X   |W   |X   |    | 3    |
|display_layout       |X   |W   |X   |    | 3    |
|process_map          |X   |W   |    |    | 2    |
|display_map          |X   |W   |    |    | 2    |
|customize_style      |X   |X   |    |    | 2    |
|Section Total        |==> |==> |==> |==> |12    |
**Data Imports**
|import_texts         |X   |X   |    |    | 2    |
|import_kmls          |X   |X   |X   |    | 3    |
|process_kmls         |X   |X   |X   |    | 3    |
|import_xlsxs         |X   |W   |X   |    | 3    |
|Section Total        |==> |==> |==> |==> |11    |
**Panel Elements (Simple)**
|process_explanation  |X   |W   |X   |    | 3    |
|display_explanation  |X   |W   |X   |    | 3    |
|process_legend_plus  |X   |X   |X   |    | 3    |
|display_legend_plus  |X   |X   |X   |    | 3    |
|process_progress     |X   |X   |X   |    | 3    |
|display_progress     |X   |X   |X   |    | 3    |
|Section Total        |==> |==> |==> |==> |18    |
**Panel Elements (Map)**
|process_routes       |X   |W   |    |    | 2    |
|display_routes       |X   |X   |    |    | 2    |
|process_opportunity  |X   |W   |    |    | 2    |
|display_opportunity  |X   |X   |    |    | 2    |
|process_travels      |X   |W   |    |    | 2    |
|display_travels      |X   |X   |    |    | 2    |
|Section Total        |==> |==> |==> |==> |12    |
**Total Progress**
|                     |Items  |Weight  |Completed |Progress Score ||
|Planning             |01 x 1 |16/100  |01        |16.0%          ||
|General Elements     |05 x 4 |01/100  |12        |12.0%          ||
|Data Imports         |04 x 4 |01/100  |11        |11.0%          ||
|Simple Panels        |06 x 4 |01/100  |18        |18.0%          ||
|Map Panels           |06 x 4 |01/100  |12        |10.0%          ||
|Total Progress       |==>    |==>     |==>       |69.0%          ||

In the table, X indicates that the task is complete.  W indicates that the task was not necessary.

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
