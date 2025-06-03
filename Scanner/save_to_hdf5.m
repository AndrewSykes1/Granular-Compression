function save_to_hdf5(image_stack,ScanNumber,path)
%This function save experimental data to a hdf5 file

filename = strcat('Scan_',num2str(ScanNumber),'.hdf5');
file=strcat(path,filename);

datasetname = strcat('/RawData/Scan_',num2str(ScanNumber));

h5write(file,datasetname,image_stack);

end