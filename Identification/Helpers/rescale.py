def rescale(data, scale, crop):
    """
    Crops and downscales a provided 3D image stack to the provided scale, which is then returned.
    
    :param data: A 3D numpy array to be passed into sk-image zoom
    :param scale: The magnitude of scaling to be done, 0.25 is to reduce 100px to 25px

    Example:
        >>> rescaledData = downscale(data, .30)
    """

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