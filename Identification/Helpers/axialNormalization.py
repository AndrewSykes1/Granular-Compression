import math
import numpy as np
from skimage import exposure

def axialNormalization(data, axis='c'):
    """
    Takes mean of an image stack across a particular axis and generates an intensity scale for normalization.

    :param data: Data to be averaged with, assumes data is of form (r,c,z)
    :param axis: Axis desired to eventually be rescaled

    Example:
    >>> 
    """

    sR,sC,sZ = np.shape(data)
    collapseDict = {
    'r': [(1,2), sR, (slice(None), np.newaxis, np.newaxis)],
    'c': [(0,2), sC, (np.newaxis, slice(None), np.newaxis)],
    'z': [(0,1), sZ, (np.newaxis, np.newaxis, slice(None))]
}
    
    info = collapseDict[axis]
    axialMeans = np.mean(data,axis=info[0])
    centralMean = axialMeans[math.floor(info[1]/2)]
    rescales = centralMean/axialMeans
    rescaleArr = np.broadcast_to(rescales[info[2]], (sR, sC, sZ))
    localNormed = data * rescaleArr
    normedData = np.clip(exposure.rescale_intensity(localNormed, in_range='image', out_range=(0,1)), 0, 1)

    return normedData
