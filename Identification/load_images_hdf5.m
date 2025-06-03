function out=load_images_hdf5(start_image,end_image,x1,x2,y1,y2,path,ScanNumber)%creates a 3d image in the region of interest

%pre-allocate matrix space
dx=x2-x1+1;% these are dimensions of the region of interest
dy=y2-y1+1;%
no_images=end_image-start_image+1;
IMS=(zeros(dy,dx,no_images));

filename = strcat('DownScan_',num2str(ScanNumber),'.hdf5');
file=strcat(path,filename);

datasetname = strcat('/RawData/Scan_', num2str(ScanNumber));

%Defines indexes for the data to load
start_index = [x1 y1 start_image];
count_index = [dx dy no_images];

%Load data
IMSr = h5read(file,datasetname,start_index,count_index);

%Permute into matlab stupid y,x,z...
IMS = double(permute(IMSr,[2 1 3]));

out=IMS;