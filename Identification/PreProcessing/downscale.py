import os
import h5py
import numpy as np

from scipy.ndimage import zoom
import matplotlib.pyplot as plt


def downscale_data(filePath, dataPath):

    # Import data
    with h5py.File(filePath,'r') as f: 
        data = f[dataPath][()] # (slices, rows, width)

    # Choose correct coordinates & crop
    data = np.transpose(data,[1,2,0]) # (rows, width, slices)
    croppedData = data[200:2448][200:2048][200:2184] #croppedData = data[150:1100,50:970,:]

    # Rescale and save
    rescaleData = zoom(croppedData, 0.25)
    flatData = np.concatenate([np.ravel(slice_) for slice_ in rescaleData])
    with h5py.File('downscale_162.hdf5', 'w') as f: 
        f.create_dataset("default", data=flatData)
        f.attrs["shape"] = rescaleData.shape


# Find files
os.chdir(r'C:\Users\Lab User\Desktop\temp1\Granular-Compression') #os.chdir('/home/snow/Coding/Granular-Compression')
file = r"Data/Scan_17.hdf5"
dataset = r'/RawData/Scan_17'

# Downscale
downscale_data(file,dataset)


# Loader example code
"""
filePath = r"Data/downscale_17.hdf5"
dataPath = r'default'

with h5py.File(filePath,'r') as f: 
    print(f.keys())
    data = f[dataPath][()] # (slices, rows, width)
    rescaleData = data.reshape(f.attrs["shape"])
"""
