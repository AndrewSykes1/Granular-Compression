%This program executes a full scan of the 3D subject

%Cropped Image dimensions
Width = 804;
Height = 826;   
LoLimX=797;
LoLimY=693;
UpLimX=LoLimX+Width-1;
UpLimY=LoLimY+Height-1;
XResolution = UpLimX-LoLimX+1;
YResolution = UpLimY-LoLimY+1;

%Input Parameters For Scan Calculations
scan_distance = 50; %in mm, the height of laser scanning
volume_length= 15 / 2.54; %in inches, the length of the current compression box
pixel_width = volume_length*25.4/Width; %in mm, the correspondance between pixel size and real distance
refraction_index = 1.49; %used to calculate relative speed of camera and laser motors
exposure_time = 300; %in ms
NumberOfCycles = 1; %In number of cycles, of those the first ten and the last ten would be high resolution ones.

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
%Input Parameters for compression cell motion
CompressionSpeed    = 0.05; % In mm per second
CompressionPercent  = 1.0; %Relative to the "current" size of container
CompressionDistance = 0.15 / 2.54;
%Compute compression steps, 1 rev = 1/10 inch, and we have 51200 steps/rev
CompressionSteps    = floor(CompressionDistance*10*51200);
%Make first 16 images per compression cycle, then 4 images per compression
%cycle. Negative values are to compress the system, positive one to detent.
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
%Input Save Settings and create directory
target_folder = 'X:\ExperimentsRawData\CyclicCompressionTwoHoles\Experiment_210227\';
mkdir(target_folder);

%Prep Compression Cell Motor
CompSetup; %uses "CompressionSpeed" and creates serial object s4

%Calculate Motor Parameters for Forward Motion
% Overall
abort_decel = 50; %in rps^2


%execute series of scans
tic
for scanNumber = 21:100
    for sign = [1,-1]
    
    %Do things intelegently, move motors, triger camera, move motors,
    %triger camera, etc...
    %Save parameters to motor controllers
    
    
    
    %Move Compression cell
    disp(['Wall Counter: ',num2str(scanNumber)]);
    disp(['Moving wall: ',num2str(sign*CompressionSteps)]);
    moveWall(sign*CompressionSteps,s4);
    
    %take note of the time motor motion started
    motionStartTime = cputime;

    

    %wait for long enough for the motors to move
    timeNeeded = (abs(CompressionSteps) / 10 / 51200 * 25.4)/CompressionSpeed;
    timeSinceMotorStart = max(cputime - motionStartTime, 0);
    disp(timeNeeded - timeSinceMotorStart + 30);
    pause((timeNeeded - timeSinceMotorStart + 30));

    %Estimate times
    ElapsedTime=toc;
    OutputTimes(ElapsedTime,scanNumber,1);
    end
end


CompClose;

%Clear and close everything
close all;

%Inform of completion
msg = msgbox('Thy will hast been done as thou hast commanded.','Scan Complete');