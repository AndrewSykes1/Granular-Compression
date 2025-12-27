import os
import h5py

def loadData(location, fileName, database='default'):
    r"""
    Recieves a file name & location, returns an unflattened version of the database contained in said file.

    :param location: Directory file is saved under
    :param fileName: File name requested to be loaded
    :param database: Database name embeded inside file

    Example:
        >>> data = loadData(location = r"C:\Users\Lab User\Desktop\temp1\Granular-Compression\Data", fileName = "downscale_17.hdf5")
    """

    # File location
    path = os.path.join(location,fileName)

    # Load and unflatten file
    with h5py.File(f'{path}','r') as f: 
        print(f.keys())
        data = f[database][()] # (slices, rows, width)
        data = data.reshape(f.attrs["shape"])
    
    return data

