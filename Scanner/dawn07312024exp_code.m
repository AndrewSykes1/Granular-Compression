%This program executes a full scan of the 3D subject

%Cropped Image dimensions
Width = 1224;
Height = 1024;   
LoLimX=0;
LoLimY=0;
% UpLimX=LoLimX+Width-1;
% UpLimY=LoLimY+Height-1;
% XResolution = UpLimX-LoLimX+1;
% YResolution = UpLimY-LoLimY+1;

%Input Parameters For Scan Calculations
scan_distance = 90; %in mm, the height of laser scanning
volume_length= 15.3 / 2.54; %in inches, the length of the current compression box
pixel_width = volume_length*25.4/Width; %in mm, the correspondance between pixel size and real distance
refraction_index = 1.49; %used to calculate relative speed of camera and laser motors
exposure_time = 50; %in ms
NumberOfCycles = 100; %In number of cycles, of those the first ten and the last ten would be high resolution ones.

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
%Input Parameters for compression cell motion
CompressionSpeed = 0.05; % In mm per second
CompressionPercent= 1; %Relative to the "current" size of container
CompressionDistance=volume_length*CompressionPercent/100.0;
%CompressionDistance=0.15 / 2.54;
%Compute compression steps, 1 rev = 1/10 inch, and we have 51200 steps/rev
CompressionSteps=floor(CompressionDistance*10*51200);
%Make first 16 images per compression cycle, then 4 images per compression
%cycle. Negative values are to compress the system, positive one to detent.
motionSeries = -floor(CompressionSteps) * (2*mod(floor(linspace(0,1,2)),2)-1)';
% -floor(CompressionSteps/8) * (2*mod(floor(linspace(0,15,16)/8),2)-1)';
numberOfScans = length(motionSeries);

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
%Input Save Settings and create directory
target_folder = 'C:\Users\Lab User\Desktop\experiment data\07312027\';
mkdir(target_folder);

%Prep Laser and Camera Motors
motorsetup; %creates serial objects s1, s2, s3 

%Prep Compression Cell Motor

CompSetup; %uses "CompressionSpeed" and creates serial object s4

%Prep Camera
%Number of vertical images, we want the same real distance to pixel ratio
%as for the horizontal direction to reconstruct 3d volumes.
imacount = floor(scan_distance/pixel_width);
%Standard glvar setup and opening of came
vid = videoinput('gentl',1,'Mono12Packed');
vid.ROIPosition = [LoLimX LoLimY Width Height];

vid.TriggerRepeat = Inf;
vid.FrameGrabInterval = 5;
vid_src = getselectedsource(vid);
vid_src.Tag = 'particle image';
vid_src.BinningHorizontal = 2;
vid_src.BinningVertical = 2;
vid_src.GainAuto = 'Off';
vid_src.Gain = 5;
vid_src.GainRaw = 50;

% vid_src.AasRoiEnable = 'True';
% vid_src.AasRoiHeight = Height;
% vid_src.AasRoiWidth = Width;
% vid_src.AasRoiOffsetX = LoLimX;
% vid_src.AasRoiOffsetY = LoLimY;

%start_camera
start(vid);
%Set exposure time in miliseconds (option 2)
vid_src = getselectedsource(vid);%display videosource with the exposuretime
vid_src.ExposureAuto = "Off";
vid_src.ExposureTime = exposure_time*1000; %set the exp time to the time above
%Obtain the exact time needed for each frame, includes exposure time and
%readout time, in seconds.
time_per_frame =exposure_time; %show_frametime(glvar.out_ptr);


%Calculate Motor Parameters for Forward Motion
% Overall
abort_decel = 50; %in rps^2
% Lasers
laser_forward_rpm = 200;

%step in microsteps. There are 50,000 microsteps per revolution (85mm)
laser_forward_targetlocations = linspace(1,imacount,imacount)*floor(scan_distance/(85*imacount)*50000);
laser_forward_accel = 40; %in rps^2
laser_forward_decel = 40; %in rps^2
% Camera
camera_forward_rpm = floor((1/refraction_index)*laser_forward_rpm); %use refractive index to calcuate camera speed
camera_forward_targetlocations = floor(laser_forward_targetlocations/refraction_index);
camera_forward_accel = 40;
camera_forward_decel = 40;

% Calculate Reverse Motor Parameters
% Lasers
laser_back_rpm = 20; %about 2.8 cm per second
nearlaser_back_targetlocation = 0; %negative limit 
farlaser_back_targetlocation = 3000;
laser_back_accel = 10; %in rps^2
laser_back_decel = 10; %in rps^2
% Camera
camera_back_rpm = 20;
camera_back_targetlocation = 0;
camera_back_accel = 10;
camera_back_decel = 10;

%Create a file holder for the images using the whole camera resolution
image_stack=zeros(Height,Width,imacount,'uint16'); 

%Home lasers and camera
motorparam(s1,laser_back_rpm,laser_back_accel,laser_back_decel,abort_decel);
motorparam(s3,laser_back_rpm,laser_back_accel,laser_back_decel,abort_decel);
motorparam(s2,camera_back_rpm,camera_back_accel,camera_back_decel,abort_decel);
moveto(s1,nearlaser_back_targetlocation);
moveto(s3,farlaser_back_targetlocation);
moveto(s2,camera_back_targetlocation);

%execute series of scans
tic
for cycleNum = 98:NumberOfCycles
cntr = cycleNum*2 + 1;
for scanNumber = 1:numberOfScans
    
    %Do things intelegently, move motors, triger camera, move motors,
    %triger camera, etc...
    %Save parameters to motor controllers
    
    motorparam(s1,laser_forward_rpm,laser_forward_accel,laser_forward_decel,abort_decel);
    motorparam(s3,laser_forward_rpm,laser_forward_accel,laser_forward_decel,abort_decel);
    motorparam(s2,camera_forward_rpm,camera_forward_accel,camera_forward_decel,abort_decel);

    %Start laser scanning
    make_scan;
   
    motorparam(s1,laser_back_rpm,laser_back_accel,laser_back_decel,abort_decel);
    motorparam(s3,laser_back_rpm,laser_back_accel,laser_back_decel,abort_decel);
    motorparam(s2,camera_back_rpm,camera_back_accel,camera_back_decel,abort_decel);

    % Move lasers and camera
    moveto(s1,nearlaser_back_targetlocation);
    moveto(s3,farlaser_back_targetlocation);
    moveto(s2,camera_back_targetlocation);
    
    %Move Compression cell
    disp(['Wall Counter: ',num2str(scanNumber)]);
    disp(['Moving wall: ',num2str(motionSeries(scanNumber))]);
    moveWall(motionSeries(scanNumber),s4);
%     
    %take note of the time motor motion started
    motionStartTime = cputime;

    %Adjust and Save images

    %if(err == 0)
        %Create current scan dataset and save it
        create_hdf5(cntr,imacount, Height,Width,target_folder);
        save_to_hdf5(image_stack(1:Height,1:Width,:),cntr,target_folder)

    %end

    %FIX
    %wait for long enough for the motors to move
    timeNeeded = (CompressionDistance*25.4)/CompressionSpeed;
    timeSinceMotorStart = max(cputime - motionStartTime, 0);
    pause((50)); %timeNeeded - timeSinceMotorStart

    %Estimate times
    ElapsedTime=toc;
    OutputTimes(ElapsedTime,scanNumber,numberOfScans);
    cntr = cntr + 1;
end
end
%Camera Shutdown
% stop_camera(glvar.out_ptr);
% if(libisloaded('GRABFUNC'))
%     unloadlibrary('GRABFUNC');
% end
% if(glvar.camera_open == 1)
%     glvar.do_close = 1;
%     glvar.do_libunload = 1;
%     pco_camera_open_close(glvar);
% end
% clear glvar;
stop(vid)
delete(vid)

%Motor Shutdown
motorclose;
CompClose;

%Clear and close everything
clear all;
close all;

%Inform of completion
msg = msgbox('Thy will hast been done as thou hast commanded.','Scan Complete');