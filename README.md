----------==========----------==========----------==========----------==========

# Overview
This project renders a 'dashboard' visualization of information about my travels
in the United States and adjacent areas of Canada. I have written many versions
of this dashboard over the years.  This one incorporates UX insights from how I
used the last one.  It will be the first one written in Python instead of R.

This version of the dashboard has six panels, each of which provides useful
information in visual and textual format.

# Task Board
The project task matrix divides the project into three stages and ten components.
Components may change between stages.  The Drafting stage is done; code is
ready for the Improving stage.

NOTE: I tried a new testing strategy for the Drafting stage of this project, but
it produced too much testing clutter and redundancy.  For the Improving stage,
I will centralize all testing into a single component.

Stages:
+ Drafting (DONE) - Build prototypes of all features and how they work together.
+ Improving – Rebuilt code, using knowledge gained from Drafting Stage.
+ Optimizing – Identify and streamline the slowest features in the code.

Component (Improving Stage):
+ 00. Libraries and Settings - Import needed functions and define settings
+ 01. Import Data – Import and shape data
+ 02. Dashboard Architecture – Build dashboard's underlying infrastructure
+ 03. Non-Map Panels - Render dashboard panels that have no map components
+ 04. Map Line Panels - Render map dashboard panels with line overlays
+ 05. Opportunity Panel - Render map dashboard panels with shading overlays
+ 06. Text Elements – Render text elements on all panels
+ 07. Testing – Conduct testing to confirm that code does what's intended
+ 08. Final Elements – Conduct any other needed tasks

## Task Matrix
|      |Dr|Im|Op|
|:-    |:-|:-|:-|
|00-Lib| X|  |  |
|01-Imp| X| X|  |
|02-Das| X| X|  |
|03-Non| X|  |  |
|04-Map| X|  |  |
|05-Opp| X|  |  |
|06-Tex| X|  |  |
|07-Tes| X|  |  |
|08-Fin| X|  |  |

Total Progress: 41% (11 of 27 tasks)

## Notes for the Improving stage:
+ Consolidate testing into a single section.
+ Swap in KNN understructure for the goal progress map?

# Directory Layout
Project directories are lettered to indicate sequences, and code scripts are
numbered for the same reason.
+ A_Input - Original input data.  It should be read but never written.
+ B_Progress - Contains intermediate data as needed.  Generally, these files
facilitate data hand-offs between scripts.
+ C_Output - Tables and visualizations that are the project's final products.
+ Z_Admin - Documentation as needed to provide guidance and context for the
project. Most significantly, this directory contains any supplemental planning material.
