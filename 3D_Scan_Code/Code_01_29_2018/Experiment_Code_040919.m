%This program executes a full scan of the 3D subject
% (AP) 10/19/18 Updated the wall motion to account for the new setup.
% (AP) 01/30/18 This version export data to hdf5.

%Cropped Image dimensions
Width = 814;
Height = 836;   
LoLimX=794;
LoLimY=706;
UpLimX=LoLimX+Width-1;
UpLimY=LoLimY+Height-1;
XResolution = UpLimX-LoLimX+1;
YResolution = UpLimY-LoLimY+1;

%Input Parameters For Scan Calculations
scan_distance = 100; %in mm, the height of laser scanning
volume_length= 6.00; %in inches, the length of the current compression box
pixel_width = volume_length*25.4/Width; %in mm, the correspondance between pixel size and real distance
refraction_index = 1.49; %used to calculate relative speed of camera and laser motors
exposure_time = 100; %in ms
NumberOfCycles = 500; %In number of cycles, of those the first ten and the last ten would be high resolution ones.


%Input Parameters for compression cell motion
CompressionSpeed = 0.05; % In mm per second
CompressionPercent= 2.0; %Relative to the "current" size of container
CompressionDistance=volume_length*CompressionPercent/100.0;
%Compute compression steps, 1 rev = 1/8 inch, and we have 51200 steps/rev
CompressionSteps=floor(CompressionDistance*10*51200);
%Make first 16 images per compression cycle, then 4 images per compression
%cycle. Negative values are to compress the system, positive one to detent.
motionSeries = -floor(CompressionSteps*[((floor(mod((1:160) - 1, 16)/8)*-2+1)/8)' ; ((floor(mod((1:((NumberOfCycles-20)*4)) - 1, 4)/2)*-2+1)/2)'; ((floor(mod((1:160) - 1, 16)/8)*-2+1)/8)' ;0]); 
numberOfScans = length(motionSeries);

%Input Save Settings and create directory
target_folder = 'X:\ExperimentsRawData\CyclicCompressionTwoHoles\Experiment_04_09_19\';
mkdir(target_folder);

%Prep Laser and Camera Motors
motorsetup; %creates serial objects s1, s2, s3 

%Prep Compression Cell Motor
CompSetup; %uses "CompressionSpeed" and creates serial object s4

%Prep Camera
%Number of vertical images, we want the same real distance to pixel ratio
%as for the horizontal direction to reconstruct 3d volumes.
imacount = floor(scan_distance/pixel_width);
%Standard glvar setup and opening of camera
glvar = struct('do_libunload',0,'do_close',0,'camera_open',0,'out_ptr',[]);
[err,glvar] = pco_camera_open_close(glvar);
pco_errdisp('pco_camera_setup',err);
%standard camera startup
%Enable binary and text timestamp data in the first pixels of the image
%(option 2). Useless, if we trim the image at the end, so set to 0.
enable_timestamp(glvar.out_ptr,0);
%Set sensor readout speed to slow 95Mhz for better quality.
set_pixelrate(glvar.out_ptr,1);

%start_camera
start_camera(glvar.out_ptr);
%Set exposure time in miliseconds (option 2)
set_exposure_time(glvar.out_ptr,exposure_time, 2);
%Obtain the exact time needed for each frame, includes exposure time and
%readout time, in seconds.
time_per_frame = show_frametime(glvar.out_ptr);
if(~libisloaded('GRABFUNC'))
    loadlibrary('grabfunc','grabfunc.h','alias','GRABFUNC');
end

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
laser_back_targetlocation = 0; %negative limit 
laser_back_accel = 10; %in rps^2
laser_back_decel = 10; %in rps^2
% Camera
camera_back_rpm = 20;
camera_back_targetlocation = 0;
camera_back_accel = 10;
camera_back_decel = 10;

%Create a file holder for the images using the whole camera resolution
image_stack=zeros(2560,2160,imacount,'uint16'); 

%Home lasers and camera
motorparam(s1,laser_back_rpm,laser_back_accel,laser_back_decel,abort_decel);
motorparam(s3,laser_back_rpm,laser_back_accel,laser_back_decel,abort_decel);
motorparam(s2,camera_back_rpm,camera_back_accel,camera_back_decel,abort_decel);
moveto(s1,laser_back_targetlocation);
moveto(s3,laser_back_targetlocation);
moveto(s2,camera_back_targetlocation);

%execute series of scans
tic
for scanNumber = 1:numberOfScans
    
    %Do things intelegently, move motors, triger camera, move motors,
    %triger camera, etc...
    %Save parameters to motor controllers
    motorparam(s1,laser_forward_rpm,laser_forward_accel,laser_forward_decel,abort_decel);
    motorparam(s3,laser_forward_rpm,laser_forward_accel,laser_forward_decel,abort_decel);
    motorparam(s2,camera_forward_rpm,camera_forward_accel,camera_forward_decel,abort_decel);
    
    %Initialise camera
    [errorCode,glvar,out_ptr,bitpix,act_xsize,act_ysize,sBufNr,temp_image,ev_ptr,im_ptr]=OpenCamera(glvar);
    
    %Start laser scanning
    make_scan;
    
    %Close camera
    [glvar]=CloseCamera(glvar,out_ptr,ev_ptr,sBufNr);

    motorparam(s1,laser_back_rpm,laser_back_accel,laser_back_decel,abort_decel);
    motorparam(s3,laser_back_rpm,laser_back_accel,laser_back_decel,abort_decel);
    motorparam(s2,camera_back_rpm,camera_back_accel,camera_back_decel,abort_decel);

    % Move lasers and camera
    moveto(s1,laser_back_targetlocation);
    moveto(s3,laser_back_targetlocation);
    moveto(s2,camera_back_targetlocation);
    
    %Move Compression cell
    moveWall(motionSeries(scanNumber),s4);
    
    %take note of the time motor motion started
    motionStartTime = cputime;
    picnum=scanNumber;

    %Adjust and Save images
    if(err == 0)
        %Create current scan dataset and save it
        create_hdf5(scanNumber,imacount,XResolution,YResolution,target_folder);
        save_to_hdf5(image_stack(LoLimX:UpLimX,LoLimY:UpLimY,:),scanNumber,target_folder)

    end
    

    %wait for long enough for the motors to move
    timeNeeded = (CompressionDistance*25.4)/CompressionSpeed;
    timeSinceMotorStart = max(cputime - motionStartTime, 0);
    pause((timeNeeded - timeSinceMotorStart));

    %Estimate times
    ElapsedTime=toc;
    OutputTimes(ElapsedTime,scanNumber,numberOfScans);
    
end

%Camera Shutdown
stop_camera(glvar.out_ptr);
if(libisloaded('GRABFUNC'))
    unloadlibrary('GRABFUNC');
end
if(glvar.camera_open == 1)
    glvar.do_close = 1;
    glvar.do_libunload = 1;
    pco_camera_open_close(glvar);
end
clear glvar;

%Motor Shutdown
motorclose;
CompClose;

%Clear and close everything
clear all;
close all;

%Inform of completion
msg = msgbox('Thy will hast been done as thou hast commanded.','Scan Complete');