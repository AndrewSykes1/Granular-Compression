import h5py
import numpy as np

for scan_number in range(185,203):

    input_file = f'./experimental_hdf5_scans/Scan_{scan_number}.hdf5'
    output_file = f'./downscaled_hdf5/DownScan_{scan_number}.hdf5'

    # Downsampling factor
    factor = 2  # Take every 2nd element
    dtype = np.float32  # Reduce precision

    with h5py.File(input_file, 'r') as f_in, h5py.File(output_file, 'w') as f_out:
        def downsample(name, obj):
            if isinstance(obj, h5py.Dataset):
                data = obj[()]
                if data.ndim >= 1:
                    slices = tuple(slice(None, None, factor) for _ in range(data.ndim))
                    data = data[slices].astype(dtype)
                else:
                    data = data.astype(dtype)
                f_out.create_dataset(name, data=data, compression='gzip')
            elif isinstance(obj, h5py.Group):
                f_out.require_group(name)

        f_in.visititems(downsample)
    
    print(f'Finished DownScan_{scan_number}')
