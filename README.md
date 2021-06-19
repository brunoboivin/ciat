# Calcium Imaging Analysis Toolbox (CIAT)
### Software package to automate and optimize calcium response analysis of entire neurons.

**Table of Contents**
- [Features](#features)
- [Publication](#publication)
  - [Abstract](#abstract)
  - [Software](#software)
- [Navigating the Project Repository](#navigating-the-project-repository)
- [Instructions for Running the Code](#instructions-for-running-the-code)
  - [Setup](#setup)
  - [Specifications](#specifications)
  - [Demo](#demo)

## Features
- MATLAB package for processing 2-photon calcium imaging data.
- Graphical user interface for manual delineation of regions of interest.
- Interface for estimating and correcting photobleaching effects.
- Noise thresholding and data smoothing capabilities.
- Neurons can be labeled according to their morphology and firing type.
- Data can be exported to a csv file or a local database.

## Publication
[Intracellular calcium responses encode action potential firing in spinal cord lamina I neurons.](https://www.jneurosci.org/content/40/23/4439.long) (Erika K. Harding<sup>1,2,3</sup>, Bruno Boivin<sup>1,4</sup>, Michael W. Salter<sup>1,2</sup>)

1. Program in Neurosciences & Mental Health, The Hospital for Sick Children, Toronto, ON, Canada.
2. Department of Physiology, University of Toronto, Toronto, ON.
3. Department of Pharmaceutical Sciences, University of Toronto.
4. F.M. Kirby Neurobiology Center, Boston Children’s Hospital and Harvard Medical School, Boston, Massachusetts.

### Abstract
Maladaptive plasticity of neurons in lamina I of the spinal cord is a lynchpin for development of chronic pain, and is critically dependent upon intracellular calcium signaling. However, the relationship between neuronal activity and intracellular calcium in these neurons is unknown. Here we combined two-photon calcium imaging with whole-cell electrophysiology to determine how action potential firing drives calcium responses within subcellular compartments of lamina I neurons. We found that single action potentials generated at the soma increase calcium concentration in the somatic cytosol and nucleus, and these calcium responses invade dendrites and dendritic spines by active backpropagation. Calcium responses in each compartment were dependent upon voltage-gated calcium channels, and somatic and nuclear calcium responses were amplified by release of calcium from ryanodine-sensitive intracellular stores. With bursts of action potentials, we found that calcium responses have the capacity to encode action potential frequency and number in all compartments. Together, these findings indicate that intracellular calcium serves as a readout of neuronal activity within lamina I neurons, providing a unifying mechanism through which activity may regulate plasticity, including that seen in chronic pain.

### Software
The software package was developed by Bruno Boivin during a studentship at SickKids (The Hospital for Sick Children, Toronto, Canada).

## Navigating the Project Repository
- The `data` folder contains data that may be specific to the equipment used such as recording time points.
- The `db` folder contains scripts for interfacing with and querying a database.
- The `functions` folder is subdivided into submodules with distinct responsibilities:
  - `drawings` is used for rendering lsm files and drawing fluorescence curves and surfaces.
  - `matrices` is used for manipulating the fluorescence matrices and to perform operations on submatrices.
  - `photobleaching` contains code to evaluate and compensate for photobleaching effects.
  - `stats` contains scripts to compute features of peaks in fluorescence and build a statistics table.
  - `utils` contains utility functions for general data manipulations.

## Instructions for Running the Code
Below are instructions for setting up your environment and using this package.

### Setup
Before using this tool, you will need to install [MathWorks' MATLAB](https://www.mathworks.com/products/matlab.html) on your machine.

1. Launch MATLAB and navigate to the project repository (e.g. /usr/bruno/ciat).
2. From the HOME tab in MATLAB's top navigation panel, click on "Set Path" and ensure that the entire ciat package is listed under the MATLAB search path. The project directory can be added to the path at once by clicking "Add with Subfolders..." and selecting the project directory "ciat".

### Specifications
- Input files consist of laser scanning microscopy files (.lsm) that contain data from two channels: green (G) and red (R).
- Times of data acquisition are listed under `data/timepoints.txt` and pertain to the equipment and experiment.
- A minimum of 264 time points are required to establish baseline activity. This parameter can be changed under the `functions/matrices` subdirectory.
- Data from the first 1986 time points get stored in a database. This can be changed by updating the supported maximum number of columns under the `gui` package and in the underlying database.

### Demo
This section will go over a simple demonstration of how to use the package with a small sample of data.

1. Launch the application by entering "mainGui" in the command window and pressing Enter. Alternatively, you can expand the ciat/gui folder, right click the mainGui.m file and click "Run".
2. In the top left corner of the input panel, click "Add lsm files" and select all files located in ciat/demo_data. This should load the data and generate colored graphs in the center of the input panel.
3. Click on "Set new region of interest" located on the right-hand side of the input panel. Enter a name for the new region of interest and adjust its location and dimensions within the Red (R) graph. A corresponding marquee will automatically appear in the Green (G) graph . For this demo, we select the entire vertical strip located between 400 and 500 along the x-axis. Once you are happy with the location and dimensions of the new region of interest, double click it to confirm your selection. This will outline the boundary of the area selected in green.
4. You can optionally specify the morphology and firing type from the dropdown menus located in the Neuron Classification subpanel within the input panel.
5. To assess and compensate for potential photobleaching effects, click the "Assess photobleaching" button located in the Settings panel at the bottom left of the interface.
6. Click the green "Start" button to start the analysis. This may open figures depending on which checkboxes were checked in the Settings panel when you clicked "Start".
7. From the storage panel located at the bottom right of the interface, enter a unique cell identifier for the data under analysis.
8. If you want to save your data to a csv file, enter the file path next to "Path to output file" in the storage panel (e.g.: usr/bruno/output/cell54.csv). The file extension must be '.csv'.
9. Alternatively, you can save your data to a database file by replacing the '.csv' extension with '.db'. If the database file specified already exists, it will add your add to it. Otherwise you will be asked whether you'd like to create a new database file.
10. The figures generated when you clicked "Start" can also be saved using the right-hand side of the storage panel of the interface.