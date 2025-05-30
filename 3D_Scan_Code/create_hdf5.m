function create_hdf5(ScanNumber,NumberOfImages,XResolution,YResolution,path)
%This create the dataset and the file if needed

filename = strcat('Scan_',num2str(ScanNumber),'.hdf5');
file=strcat(path,filename);

datasetname = strcat('/RawData/Scan_',num2str(ScanNumber));

size = [XResolution YResolution NumberOfImages];
ChunkSize = [XResolution YResolution 1];

h5create(file,datasetname,size,'Datatype','uint16','ChunkSize',ChunkSize, ...
        'Shuffle',true,'Deflate',4,'Fletcher32',true);


end