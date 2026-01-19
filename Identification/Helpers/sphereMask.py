import numpy as np

def sphereMask(diameter, pad, scale=1):
    """
    Creates a binary sphere mask centered at the origin (0,0,0)
    
    Parameters:
    :param diameter: Diameter of particle in reality
    :param pad: Desired blank side padding 
    :param scale: Downscaled magnitude compared to reality (.25 => OG*.25=Scan)
    """
    
    # Calculate mask properties
    diameter = np.round(diameter*scale,0)
    pad = round(pad*(2*scale),0)
    wall = diameter/2+pad

    # Create grid map
    x,y,z = np.ogrid[-wall:wall+1,-wall:wall+1,-wall:wall+1]
    mask = np.sqrt(x**2+y**2+z**2)
    
    # Scale values
    a,b,c = mask.shape
    mask[mask > diameter/2] = 0
    mask[mask != 0] = 255
    mask[int(a/2),int(b/2),int(c/2)] = 255
    
    return mask