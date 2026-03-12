import numpy as np

def idealParticleGrid(radialGrid, diameter, width):
    """
    Calculate ideal particle image with smooth edge falloff.
    
    Parameters:
    -----------
    radialGrid
        Grid of radial distances from particle center
    diameter
        Diameter of the particle
    width
        Width parameter controlling edge sharpness.
        2*width represents the distance over which 76% of the intensity falloff occurs
    
    Returns:
    --------
    ipImage
        Image of ideal particle with values from 0 (far from particle) to 1 (center)
    """
    # Calculate normalized distance from particle edge
    distance_from_edge = (np.abs(radialGrid) - diameter/2) / width
    
    # Create smooth falloff using tanh
    ipImage = (1 - np.tanh(distance_from_edge)) / 2
    
    return ipImage