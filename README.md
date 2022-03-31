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
0. Data Acquisition - Import and refine all needed data.
1. Plot Infrastructure - Basic plotting canvas that will underly all panels.
2. Generic Panel Elements - Generic functions to add explanatory text and titles.
3. Introduction Panel -  Explanation of the dashboard.
4. Progress Panel - Bar chart of progress towards reaching travel goals.
5. Opportunity Panel - Map of opportunity to make goal progress.
6. Route Panel - Map of planned future travel routes.
7. Table Panel - Information about each planned route.
8. Travel Panel - Map of past travels.
9. Code Tests - Tests for all features.

## Task Matrix
|     |Dr|Im|Op|
|:-   |:-|:-|:-|
|00-DA| X|  |  |
|01-PI| X|  |  |
|02-GP| X|  |  |
|03-IP| X|  |  |
|04-PP| X|  |  |
|05-OP| X|  |  |
|06-RP| X|  |  |
|07-TP| X|  |  |
|08-TP| X|  |  |
|09-CT| X|  |  |

Total Progress: 33%

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
