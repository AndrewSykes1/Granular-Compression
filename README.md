# Granular Matter Compression Experiment

This codebase supports an experiment led by Dr. Peshkov, investigating how granular materials — specifically Orbeez-like particles in a Triton solution — respond to repeated mechanical compression.

## Overview

The experimental setup involves:

- **Two vertically-moving lasers**: These scan the surface of the particle setup to assist with alignment and calibration.
- **A motorized camera system**: Captures a side view of the particles during compression cycles.
- **Video processing pipeline**: The recorded footage is cropped, stabilized, and converted into an HDF5 image stack for analysis.
- **Particle detection**: Image processing techniques identify the centers of individual particles throughout the compression process.

## Research Goal

The main objective is to determine how particle behavior changes under cyclic compression. Specifically:

- **Do particles shift position over time?**
- **Does their orientation or rotation change?**

According to prior studies, particle **positions tend to remain constant**, while **rotations evolve with each compression cycle**.  
Our aim is to replicate these findings and explore whether additional variables influence this behavior.
