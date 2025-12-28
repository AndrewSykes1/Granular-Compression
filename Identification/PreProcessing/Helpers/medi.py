import numpy as np

from scipy.ndimage import median_filter

def medi(data, highPct=99, medPct=95):
    """
    Applies a 3d median filter to a provided set of data.

    :param data: A 3d numpy array representing an image stack
    :param highPct: Cutoff threshold to be capped at
    :param medPct: Percentile of brightness to replace overly bright data with
    """

    # Apply median filter and threshold
    threshHigh = np.percentile(data, highPct)
    filteredData = median_filter(data, size=(3, 3, 3))
    data[data > threshHigh] = filteredData[data > threshHigh]

    # Update threshold and replace values above it with the median
    threshHigh = np.percentile(data, highPct)
    data[data > threshHigh] = np.mean(np.percentile(data, medPct))

    return data