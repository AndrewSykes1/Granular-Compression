function makeHDF5(imgNumber,scanNum,XResolution,YResolution,path)

% File name and save location
scanString  = strcat('Scan_',num2str(scanNum));
datasetName = strcat('/RawData/',scanString);
filePath    = strcat(path,scanString,'.hdf5');

% Define stored data's shape
dataSize  = [XResolution YResolution imgNumber];
chunkSize = [XResolution YResolution 1];

% Create schema
h5create(filePath,datasetName,dataSize, ... 
    'Datatype','uint16', ... 
    'Fletcher32',true, ...
    'ChunkSize',chunkSize, ...   % Data group to compress
    'Shuffle',true,'Deflate',4); % Compression magnitude
end