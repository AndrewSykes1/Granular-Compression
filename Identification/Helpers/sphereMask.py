import numpy as np

def sphereMask(shape, D=100, scale=1):
    """
    Creates a binary sphere mask centered at the origin (0,0,0)
    
    Parameters:
    :param shape: Desired dimensions of array as a list
    :param D: Diameter of particle in reality scan 
    :param scale: How downscaled scan is compared to reality (.25 implies OG*.25=Scan)
    """
    l = 25
    r = 20

    x,y,z = np.ogrid[-l:l,-l:l,-l:l]
    gri = np.sqrt(x**2+y**2+z**2)
    gri[gri > r] = 0
    gri[gri != 0] = 1
        
    return mask