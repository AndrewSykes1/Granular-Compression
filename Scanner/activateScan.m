% Suppress deprecation warnings
warning('off', 'instrument:serial:ClassToBeRemoved');
warning('off', 'instrument:instrfindall:FunctionToBeRemoved');

% Delete all serial and camera objects in memory
delete(instrfindall);
clear all;
imaqreset;


%% Establish constants %%

% General
volWidth   = 6.50; % Compression axis (in)
volHeight  = 6.00; % Horizontal plane length
volLength  = 5.00; % Vertical fluid height
compDepth  = 0.50; % Plate thickness
totalScans = 100;  % Number of scans       

% Camera
LoLimX=0; Width  = 1216;
LoLimY=0; Height = 1024;
pxDensity = (Width/(volWidth+compDepth) + Height/volHeight)/2;
imgCount  = int32(pxDensity*volLength);  % Number of images in stack
imgStack  = zeros(Height, Width, imgCount, 'uint16');

% Compression Motor
compConv  = 500000; % Conversion of (microstep/in)
compVelocity = 0.78; % Speed of compression (in/s)
compPercent  = .10; % Percent of container to compress
compStep = floor(volWidth*compPercent*compConv); % Motor steps to compress said distance (steps) [1rev]=[1/10inch], [51200steps/rev],[512000steps/in]

% LaseCam Motors
motorTargets = linspace(1,volLength*12800,imgCount); % [12800u/in]
motorForwardRpm = 8;   motorReverseRpm = 20;  % Forward vel (rpm)
motorForwardAcc = 40;  motorReverseAcc = 10;  % Forward acc (rps^2)
motorForwardDcc = 40;  motorReverseDcc = 10;  % Forward dcc (rps^2)
motorHome = 0;         motorAbortDcc   = 50;  


%% Setup Motors %%
nearLaserCom = 'COM5'; camCom  = 'COM2';
farLaserCom  = 'COM1'; compCom = 'COM4';

motorSetup; % Create s1:Near, s2:Camera, s3:Far
compSetup;  % Create s4:Comp
camSetup;   % Configure camera

makeDirectory; % Create directory
disp('Motors and Cam setup complete')


%% Execute series of scans %% 
for scanNumber = 1:totalScans
    timeInfo;    % Show time estimates

    homeLaseCam; % Home LaseCam
    makeScan;    % Scan volume
    moveWall;    % Compress cell
end

% Inform of completion
msg = msgbox('Thy will hast been done as thou hast commanded.','Scan Complete');
