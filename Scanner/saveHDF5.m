function saveHDF5(data,scanNum,path)

% File name and save location
scanString  = strcat('Scan_',num2str(scanNum));
datasetName = strcat('/RawData/',scanString);
filePath    = strcat(path,scanString,'.hdf5');

% Define database's shape
dataSize  = size(data);
chunkSize =[dataSize(1:2) 1];

% Create schema
h5create(filePath,datasetName,dataSize, ... 
    'Datatype','uint16', ... 
    'Fletcher32',true, ...
    'ChunkSize',chunkSize, ...   % Grouping to compress by
    'Shuffle',true,'Deflate',4); % Compression magnitude

% Write file
h5write(filePath,datasetName,data);

end