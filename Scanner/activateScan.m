% Suppress deprecation warnings
warning('off', 'instrument:serial:ClassToBeRemoved');
warning('off', 'instrument:instrfindall:FunctionToBeRemoved');

% If some variable exists, then do X, if not, then define some group of
% variables

% Delete all serial and camera objects in memory
delete(instrfindall);
clear all;
imaqreset;


%% Establish constants

% General
volWidth    = 6.50; % Compression axis (in)
volHeight   = 6.00; % Horizontal plane length
volLength   = 7; % Vertical fluid height (5.5 usually)
compDepth   = 0.50; % Plate thickness
totalCycles = 200;  % Number of Cycles
resShift    = 10;   % How many cycles before shifting to low res cycles

% Camera
LoLimX=0; Width  = 1216;
LoLimY=0; Height = 1024;
pxDensity = (Width/(volWidth+compDepth) + Height/volHeight)/2;
imgCount  = int32(pxDensity*volLength);  % Number of images in stack
imgStack  = zeros(Height, Width, imgCount, 'uint16');

% Compression Motor
compConv  = 500000;  % Conversion of (microstep/in)
compVelocity = 0.78; % Speed of compression (in/s)
compPercent  = 0.10; % Percent of container to compress
compStep = floor(volWidth*compPercent*compConv); % Motor steps to compress said distance (steps) [1rev]=[1/10inch], [51200steps/rev],[512000steps/in]
resHighCnt = 8; % How many scans for "high res cycle"
resLowCnt  = 4; % How many scans for "low res cycle"
[lowTargets, highTargets] = compStepArray(compStep,resLowCnt,resHighCnt);

% LaseCam Motors
motorTargets = round(linspace(1,volLength*12800,imgCount)); % [12800u/in]
motorForwardRpm = 8;   motorReverseRpm = 20;  % Forward vel (rpm)
motorForwardAcc = 40;  motorReverseAcc = 10;  % Forward acc (rps^2)
motorForwardDcc = 40;  motorReverseDcc = 10;  % Forward dcc (rps^2)
motorAbortDcc   = 50;  


%% Setup Motors
nearLaserCom = 'COM9'; camCom  = 'COM6';
farLaserCom  = 'COM1'; compCom = 'COM8';

motorSetup; % Create s1:Near, s2:Camera, s3:Far
compSetup;  % Create s4:Comp
camSetup;   % Configure camera

makeDirectory; % Create directory
disp('Motors and Cam setup complete')


%% Execute series of cycles
for cycleNumber = 1:totalCycles
    homeLaseCam;

    % Use high res targets for first and last 10 cycles
    if cycleNumber <= resShift || cycleNumber >= (totalCycles-resShift)
        for i = 1:length(highTargets)
            moveWall(s4,highTargets(i));
            if i < length(highTargets)
                makeScan;
            end
        end

    % Use low res targets for all other cycles
    elseif cycleNumber > resShift
        for i = 1:length(lowTargets)
            moveWall(s4,lowTargets(i));
            if i < length(lowTargets)
                makeScan;
            end
        end
    end

    fprintf('Completed cycle: %d\n', cycleNumber);

end

% Inform of completion
msg = msgbox('Thy will hast been done as thou hast commanded.','Scan Complete');
