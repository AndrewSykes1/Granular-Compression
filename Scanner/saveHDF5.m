function saveHDF5(data,cycleNum,subCycleNum,path)

% File name and save location
cycleString = strcat('Cycle',num2str(cycleNum),'s',num2str(subCycleNum));
datasetName = strcat('/RawData/',cycleString);
filePath    = strcat(path,cycleString,'.hdf5');

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