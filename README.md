----------==========----------==========----------==========----------==========

# Overview
This project renders a 'dashboard' visualization of information about my travels
in the United States and adjacent areas of Canada. I have written many versions
of this dashboard over the years.  This one incorporates UX insights from how I
used the last one.  It will be the first one written in Python instead of R.

This version of the dashboard has six panels, each of which provides useful
information in visual and textual format.

# Task Board
The project task matrix divides the project into three stages and nine
components. Components may change between stages.  The Drafting and Improving
stages are complete.  The Optimizing stage is currently a low priority until
development on other projects has progressed further.

Stages:
+ Drafting (DONE) - Build prototypes of all features and how they work together.
+ Improving (DONE) – Rebuild code using knowledge gained from Drafting Stage.
+ Optimizing – Identify and streamline the slowest features in the code.

Component (Improving Stage):
+ 00. Libraries and Settings - Import needed functions and define settings
+ 01. Import Data – Import and shape data
+ 02. Dashboard Architecture – Build the dashboard's underlying infrastructure
+ 03. Non-Map Panels - Render dashboard panels that have no map components
+ 04. Common map elements - Render the base map layer under each map panel
+ 05. Map panels - Render map dashboard panels
+ 06. Text Elements – Render text elements on all panels
+ 07. Testing – Conduct testing to confirm that code does what's intended
+ 08. Final Elements – Conduct any other needed tasks

## Task Matrix
|      |Dr |Im |Op |
|:-    |:- |:- |:- |
|00-Lib| X | X |   |
|01-Imp| X | X |   |
|02-Das| X | X |   |
|03-Non| X | X |   |
|04-Com| X | X |   |
|05-Map| X | X |   |
|06-Tex| X | X |   |
|07-Tes| X | X |   |
|08-Fin| X | X |   |
|N     |9.0|9.0|0.0|
|W     | 55| 30| 15|

Total Progress: (55 * 9.0 + 30 * 9.0 + 15 * 0.0) / 9 = 85%

## TODO
+ Swap out TextWrapper for something more anchored in basic Python str methods
    + Note: also has issues when the length of a .format() insertion is long.
+ Make docx importer ignore temporary files

# Directory Layout
Project directories are lettered to indicate sequences, and code scripts are
numbered for the same reason.
+ A_Input - Original input data.  It should be read but never written.
+ B_Progress - Contains intermediate data as needed.  Generally, these files
facilitate data hand-offs between scripts.
+ C_Output - Tables and visualizations that are the project's final products.
+ Z_Admin - Documentation as needed to provide guidance and context for the
project. Most significantly, this directory contains any supplemental planning material.
