# ciat
Calcium Imaging Analysis Toolbox 

**Table of Contents**
- [Software Abstract](#software-abstract)
- [Publication](#publication)
  - [Abstract](#abstract)
- [Navigating the Project Repository](#navigating-the-project-repository)
- [Instructions for running the code](#instructions-for-running-the-code)
  - [Setup](#setup)
  - [Using the package](#using-the-package)
  - [Building your first app](#building-your-first-app)

## Software Abstract
TO BE COMPLETED

## Publication
- Intracellular calcium responses encode action potential firing in spinal cord lamina I neurons.
- Erika K. Harding<sup>1,2,3</sup>, Bruno Boivin<sup>1,4</sup>, Michael W. Salter<sup>1,2</sup>.

1. Program in Neurosciences & Mental Health, The Hospital for Sick Children, Toronto, ON, Canada.
2. Department of Physiology, University of Toronto, Toronto, ON.
3. Department of Pharmaceutical Sciences, University of Toronto.
4. F.M. Kirby Neurobiology Center, Boston Children’s Hospital and Harvard Medical School, Boston, Massachusetts.

### Abstract
Maladaptive plasticity of neurons in lamina I of the spinal cord is a lynchpin for development of chronic pain, and is critically dependent upon intracellular calcium signaling. However, the relationship between neuronal activity and intracellular calcium in these neurons is unknown. Here we combined two-photon calcium imaging with whole-cell electrophysiology to determine how action potential firing drives calcium responses within subcellular compartments of lamina I neurons. We found that single action potentials generated at the soma increase calcium concentration in the somatic cytosol and nucleus, and these calcium responses invade dendrites and dendritic spines by active backpropagation. Calcium responses in each compartment were dependent upon voltage-gated calcium channels, and somatic and nuclear calcium responses were amplified by release of calcium from ryanodine-sensitive intracellular stores. With bursts of action potentials, we found that calcium responses have the capacity to encode action potential frequency and number in all compartments. Together, these findings indicate that intracellular calcium serves as a readout of neuronal activity within lamina I neurons, providing a unifying mechanism through which activity may regulate plasticity, including that seen in chronic pain.

## Navigating the Project Repository
- The `data` folder contains fixed data that may be specific to the equipment used.
- The `db` folder contains scripts for interfacing with and querying a database.
- The `functions` folder is subdivided into submodules of functions with distinct responsibilities:
  - `drawings` is used for rendering lsm files and drawing fluorescence curves and surfaces.
  - `matrices` is used for manipulating the fluorescence matrices and perform operations on submatrices.
  - `photobleaching` contains code to evaluate and compensate for photobleaching effects.
  - `stats` contains scripts to compute peak features and build a statistics table.
  - `utils` contains utility functions for general purpose data manipulations.

## Instructions for running the code
Below are instructions for setting up your environment and using this package.

### Setup
Before using this package, you will need to install [MathWorks' MATLAB](https://www.mathworks.com/products/matlab.html) on your machine.

1. TO BE COMPLETED

### Using the package
TO BE COMPLETED

### Building your first app
TO BE COMPLETED

### Testing
TO BE COMPLETED
