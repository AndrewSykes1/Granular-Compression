# Granular Matter Compression

## Overview
This codebase supports an experiment led by Dr. Peshkov at Cal State Fullerton. Namely, it provides the functionality to the physical apparatus for scanning a volume containing about 700 Hydrogel orbs submerged in a solution of Triton dyed using NileBlue which is repeatedly compressed, as well as the actual detection of the space those orbs take up using convolution and distance transforms. It is planned to create tracking functionality on these particles which would allow data analysis to see how they change their position over time.

## Research Goal

The main objective of this experiment is to determine how soft matter particles behave under cyclic compression. Specifically, how they compare to hard particles under similar conditions.

According to prior studies, particle **positions tend to remain constant**, while **rotations evolve with each compression cycle** but this has yet to be studied or confirmed with soft particles.  
Our aim is to replicate these findings and explore whether additional variables influence this behavior.

## Physical Setup

- **Motorized lasers**: Lasers outputting a horizontal laser sheet are attached to 2 beams across from each other with a belt wrapping around each of them ending up at a stepper motor for each to raise and lower. <br>
When lasers are on, it intersects with the apparatus horizontally creating a cross sectional area of a given height level visible from above.

- **Motorized camera system**: To record the visible cross section, a mirror mounted at a 45 degree angle is placed above the apparatus with a camera pointed at it. But as the lasers height becomes closer or farther to the mirror, it is necessary to move the camera closer or further to not have to readjust the focus using the same belt system as the laser.

- **Full scan**: Commanded by a matlab script, the lasers and camera move in harmony to record a full scan of the volume which is saved to a hard drive on the attached computer. A metal plate is then extended into the volume to compress the particles after which another scan is taken. In total this cycle is repeated over 100 times creating a lot of data.

## Computational Methods

- **Image preprocessing**: The 3d image full of brightness values contains the following important noise sources: Laser diffraction beams, Gaussian noise via natural brightness fluctuations, Poisson noise from camera imperfections, & Salt and Pepper noise from dust particles.
<br>
[-] Laser diffraction beams can be denoised via Hough Transforms to identify straight lines propagated throughout a 2d image, which is then applied to the total image.
<br>
[-] Gaussian noise can be removed by a simple 3d Gaussian blur image subtraction
<br>
[-] Poisson noise is hard to remove but is not so damaging to ruin the convolution step described later.
<br>
[-] Salt and Pepper noise can be removed using a 3d median filter over each voxel.

- **Particle center detection**: To find accurate voxel positions, a convolution and distance transform center detection were created to accurately identify a center. Both of these are applied in the standard fashion except with the quirk of using a fast fourier transform with convolution to decrease runtime whilst also being parallelized to be gpu runnable.

- **Data storage**: After centers of particles are detected over each scan, these coordinates are saved to an array in a .mat file along with the overall post processed volume.

## Data Analysis

- **Data Visualization**: To visualize the data, a python notebook loads the .mat data into an array which can then be visualized using napari. The script overlays detect peak coordinates over the semi-transparent volume for a single inputted scan. Because of the size, a widget was created to control the range of volume and peaks displayed over the z domain.

- **Tracking info**: Not implemented yet.

## Credit

| Person | Role |
|-------|-----|
Dr. Anton Peshkov | Instruction of undergrads
Daniel Parez | Construction of apparatus
Andrew Sykes | Creation of computational works

[Add the mysterious 2 others later]

## License
[MIT](LICENSE.md)
