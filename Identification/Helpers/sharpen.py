import numpy as np
from skimage import exposure
from scipy.ndimage import gaussian_filter

def sharpen(data, std=3, strength=0.2):
    """
    Applies a reductive gaussian blur to data.
    
    :param data: Image stack to be reduced
    :param std: Deviation of gaussian filter being applied
    :param strength: How strongly the blur reduction should apply
    """

    blurred = gaussian_filter(data, sigma=std)
    dataSharp = np.clip(data - strength*blurred, 0, 1)
    #redistribute = np.clip(exposure.rescale_intensity(dataSharp, in_range='image', out_range=(0,1)), 0, 1)

    return dataSharp