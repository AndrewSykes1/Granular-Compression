% Delete all serial and camera objects in memory
delete(instrfindall);
clear s1 s2 s3 s4;
imaqreset;

%%% Execute a full scan of the 3D subject %%%

%%% Establish constants %%%
% Image capture region
LoLimX=0;
LoLimY=0;
Width = 1224;
Height = 1024;   

%Input Parameters For Scan Calculations
scan_distance    = 90;                                % Height(mm) of scanned volume 
volume_length    = 15.3/2.54;                         % Length(in) of volume compressed
pixel_width      = volume_length*25.4/Width;          % Pixel to distance conversion constant (mm/px)
imacount         = floor(scan_distance/pixel_width);  % Number of images in stack

refraction_index = 1.49;                              %used to calculate relative speed of camera and laser motors (No clue if this is reasonable)
exposure_time    = 50;                                % Exposure time (ms)
NumberOfCycles   = 100;                               % Number of compressions per cycle, first and last ten are high res ones.

%Input Parameters for compression cell motion
CompressionSpeed    = 0.05;                                    % Speed of compression (mm/s)
CompressionPercent  = 1;                                       % Percent of 'current' container size to compress
CompressionDistance = volume_length*CompressionPercent/100.0;  % Distance to compress (mm)
CompressionSteps    = floor(CompressionDistance*10*51200);     % Motor steps to compress said distance (steps)
                                                               % [1rev]=[1/10inch], [51200steps/rev]
abort_decel = 50;                                              % Emergency stop deceleration (rps^2)

% Instruction list of number of 'steps' in order to compress then decompress (- to compress, + to decompress)                                                             
motionSeries = -floor(CompressionSteps)  *(2*mod(floor(linspace(0, 1, 2)  ),2)-1)'; % Make 4 images per cycle 
%              -floor(CompressionSteps/8)*(2*mod(floor(linspace(0,15,16)/8),2)-1)'; % Make 16 images per cycle
numberOfScans = length(motionSeries);
disp('Constants established')



%%% Input Save Settings and create directory %%%
directory_folder = 'C:\Users\Lab User\Desktop\ModernExperiments\';
info = string({dir(directory_folder).name});
x = str2double(extractAfter(info(startsWith(info, 'exp_')), 4));
target_folder = fullfile(directory_folder, sprintf('exp_%d', max(x)+1), '\');
mkdir(target_folder)
disp('Created Directory')



%%% Prep All %%%
% Prep Motors
motorsetup;     % Create serial objects s1, s2, s3 
CompSetup;      % Use "CompressionSpeed" and create s4

% Config Camera
vid = videoinput('gentl',1,'Mono12Packed');     % Standard glvar setup
vid.ROIPosition = [LoLimX LoLimY Width Height]; % Crop camera

% Trigger settings
vid.TriggerRepeat = Inf;           % Enable continous scanning
vid.FrameGrabInterval = 5;         % Store only every 5th frame

% Obtain source
vid_src = getselectedsource(vid);
vid_src.Tag = 'particle image';

% Pooling by addition
vid_src.BinningHorizontal = 2;    % Horizontal pixel addition
vid_src.BinningVertical = 2;      % Verticle pixel addition

% Set gain
vid_src.GainAuto = 'Off';
vid_src.Gain = 5;
vid_src.GainRaw = 50;

% Start camera
start(vid);
vid_src = getselectedsource(vid);

% Set exposure settings                            
vid_src.ExposureAuto = "Off";
vid_src.ExposureTime = exposure_time*1000;  % Set exposure time in microseconds
time_per_frame = exposure_time;             % Find time to obtain each frame
disp('Camera configured')



%%% Motor Config %%%
% Forward Laser
laser_forward_targetlocations = linspace(1,imacount,imacount)*floor(scan_distance/(85*imacount)*50000);  % Laser goal locations [50,000microsteps]=[1rev] [1rev]=[85mm]
laser_forward_rpm   = 200;  % Forward vel (rpm)
laser_forward_accel = 40;   % Forward acc (rps^2)
laser_forward_decel = 40;   % Forward dcc (rps^2)

% Forward Camera
image_stack                    = zeros(Height, Width, imacount, 'uint16');               % Create blank image stack
camera_forward_targetlocations = floor(laser_forward_targetlocations/refraction_index);  % Camera goal locations
camera_forward_rpm             = floor((1/refraction_index)*laser_forward_rpm);          % Forward vel (rpm)
camera_forward_accel           = 40;                                                     % Forward acc (rps^2)
camera_forward_decel           = 40;                                                     % Forward dcc (rps^2)

% Reverse Lasers
laser_back_rpm = 20;                  % Reverse vel (rpm) | 20[rpm] ~ 2.8[cm/s]
laser_back_accel = 10;                % Reverse acc (rps^2)
laser_back_decel = 10;                % Reverse dcc (rps^2)
nearlaser_back_targetlocation = 0;    % Lower position bound for far laser
farlaser_back_targetlocation = 3000;  % Lower position bound for close laser

% Reverse Camera
camera_back_rpm = 20;             % Reverse vel (rpm)
camera_back_accel = 10;           % Reverse acc (rps^2)
camera_back_decel = 10;           % Reverse dcc (rps^2)
camera_back_targetlocation = 0;   % Lower position bound for camera

% Home LaseCam
motorparam(s1, laser_back_rpm,  laser_back_accel,  laser_back_decel,  abort_decel);
motorparam(s3, laser_back_rpm,  laser_back_accel,  laser_back_decel,  abort_decel);
motorparam(s2, camera_back_rpm, camera_back_accel, camera_back_decel, abort_decel);
moveto(s1, nearlaser_back_targetlocation);
moveto(s3, farlaser_back_targetlocation);
moveto(s2, camera_back_targetlocation);
disp('Motors Homed')


pause(10);

%%% Execute series of scans %%%
tic
for cycleNum = 98:NumberOfCycles
cntr = 1;
for scanNumber = 1:numberOfScans
    
    % Set LaseCam into forward mode
    motorparam(s1, laser_forward_rpm,  laser_forward_accel,  laser_forward_decel,  abort_decel);
    motorparam(s3, laser_forward_rpm,  laser_forward_accel,  laser_forward_decel,  abort_decel);
    motorparam(s2, camera_forward_rpm, camera_forward_accel, camera_forward_decel, abort_decel);

    % Begin laser scanning
    make_scan;
   
    % Re-home LaseCam
    motorparam(s1, laser_back_rpm,  laser_back_accel,  laser_back_decel,  abort_decel);
    motorparam(s3, laser_back_rpm,  laser_back_accel,  laser_back_decel,  abort_decel);
    motorparam(s2, camera_back_rpm, camera_back_accel, camera_back_decel, abort_decel);
    moveto(s1, nearlaser_back_targetlocation);
    moveto(s3, farlaser_back_targetlocation);
    moveto(s2, camera_back_targetlocation);
    
    % Begin Compression
    moveWall(motionSeries(scanNumber),s4);
    motionStartTime = cputime;             % Note time of comp motor initialization
    disp(['Wall Counter: ', num2str(scanNumber)]);
    disp(['Moving wall: ' , num2str(motionSeries(scanNumber))]);

    % Save current scan
    create_hdf5(cntr, imacount, Height, Width, target_folder);
    save_to_hdf5(image_stack(1:Height,1:Width,:), cntr, target_folder)

    % Pause to allow motor motion
    timeNeeded = (CompressionDistance*25.4)/CompressionSpeed;
    buffer     = 10;
    pause((timeNeeded + buffer));

    %Estimate times
    ElapsedTime = toc;
    OutputTimes(ElapsedTime, scanNumber, numberOfScans);
    cntr = cntr + 1;
end
end

%%% Reset %%%
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