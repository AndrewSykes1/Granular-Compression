file = './staged_data/downscaling/downscaled_hdf5/DownScan_202.hdf5';
dataset = '/RawData/Scan_202';

info = h5info(file, dataset);
dims = info.Dataspace.Size;

disp(['Dataset dimensions: ' num2str(dims)]);

% Dataset dimensions: 512  612  360