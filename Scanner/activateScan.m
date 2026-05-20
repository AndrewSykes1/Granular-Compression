% Supress deprication warnings
warning('off', 'instrument:serial:ClassToBeRemoved');
warning('off', 'instrument:instrfindall:FunctionToBeRemoved');

% Delete all serial and camera objects in memory
delete(instrfindall);
clear all;
imaqreset;

%% Establish constants %%

% General
volumeLen = 15.3/2.54;   % Length(in) of volume compressed
containerHeight = 50000; % Units of (u)
abortDcc = 50;           % Emergency stop deceleration (rps^2)

% Camera
LoLimX=0; Width  = 1224;
LoLimY=0; Height = 1024;
exposureTime = 50;   % Exposure time (ms)
imgCount     = 500;  % Number of images in stack
imgStack = zeros(Height, Width, imgCount, 'uint16');

% Compression Motor
compVelocity = 0.2;                          % Speed of compression (mm/s)
compPercent  = 1;                            % Percent of 'current' container size to compress
compDistance = volumeLen*compPercent/100.0;  % Distance to compress (mm)
compStep     = -floor(compDistance*10*51200); % Motor steps to compress said distance (steps) [1rev]=[1/10inch], [51200steps/rev]


% LaseCam Motors
motorTargets = linspace(1,containerHeight,imgCount);
motorForwardRpm = 8;  motorReverseRpm = 20;  % Forward vel (rpm)
motorForwardAcc = 40;  motorReverseAcc = 10;  % Forward acc (rps^2)
motorForwardDcc = 40;  motorReverseDcc = 10;  % Forward dcc (rps^2)                                                % Forward dcc (rps^2)
motorHome = 0;  % Home location

%% Setup Motors%%
nearLaserCom = 'COM5'; cameraCom = 'COM2';
farLaserCom  = 'COM1'; compCom   = 'COM4';

motorsetup;    % Create s1:Near, s2:Camera, s3:Far
CompSetup;     % Create s4:Comp
camSetup;      % Configure camera
makeDirectory; % Create directory
disp('Motors and Cam setup complete')

%% Execute series of scans %%
totalScans = 10;
cntr = 1; tic; startScanMsg;  % Current time

for scanNumber = 1:totalScans

    homeLaseCam;    % Home Motors
    pauseMotor;     % Wait for homing
    forwardLaseCam; % Set forward

    makeScan; % Scan
    saveScan; % Save scan to HDF5
    moveWall; % Compress cell
    
    estFinish;  % Estimate time till finish
    cntr = cntr + 1;
end

%% Reset %%
% Video
stop(vid)
delete(vid)

% Motor
motorclose;
CompClose;

% Variables
clear all;
close all;

% Inform of completion
msg = msgbox('Thy will hast been done as thou hast commanded.','Scan Complete');
