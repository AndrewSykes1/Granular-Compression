import os
import h5py
import numpy as np

def saveData(data, location, saveName):
    r"""
    Saves a unflattened database as an hdf5 file which can be recieved
    at a later time. Refer to LoadData.py in order to retrieve the 
    saved file in a useable mannar.
    
    :param data: 3D numpy array representing experiment image stack
    :param location: Directory file is to be saved under
    :param saveName: Name file is to be saved as
    
    Example:
        >>> saveData(data=data, location = r"C:/Users/Lab User/Desktop/temp1/Granular-Compression/Data, saveName = downscale_17.hdf5)
    """

    # Change directory to save location
    path = os.path.join(location,saveName)

    # Flatten and save data
    flatData = np.concatenate([np.ravel(slice_) for slice_ in data])
    with h5py.File(path, 'w') as f: 
        f.create_dataset("default", data=flatData)
        f.attrs["shape"] = data.shape