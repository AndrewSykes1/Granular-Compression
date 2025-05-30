%This program executes a full scan of the 3D subject

%Input Parameters For Scan Calculations
scan_distance = 90; %in mm, the height of laser scanning
volume_length=6.15; %in inches, the length of the current compression box
pixel_width = floor(volume_length*25.4)/850; %in mm, the correspondance between pixel size and real distance
refraction_index = 1.49; %used to calculate relative speed of camera and laser motors
exposure_time = 40; %in ms

%Input Parameters for compression cell motion
CompressionSpeed = 50; % speed in steps per second (max 100)
CompressionPercent=1; %Relative to the "current" size of container
CompressionDistance=volume_length*CompressionPercent/100.0;
CompressionSteps=floor(CompressionDistance*20*800); % 800 steps = 1/20 inch
%Make first 16 images per compression cycle, then 4 images per compression
%cycle
motionSeries = CompressionSteps*[((floor(mod((1:160) - 1, 16)/8)*-2+1)/8)' ; ((floor(mod((1:1520) - 1, 4)/2)*-2+1)/2)'; ((floor(mod((1:160) - 1, 16)/8)*-2+1)/8)' ;0]; %compression cell motion series (in steps) 800 steps = 1/20 in
numberOfScans = length(motionSeries);

%Input Save Settings
target_folder = 'E:\ExperimentsResults\SingleHoleCompression\Run_121417\';
scanFolderName = 'Scan';
ImgName = 'Image';
Extension = '.tif';

%Prep Laser and Camera Motors
motorsetup; %creates serial objects s1, s2, s3 

%Prep Compression Cell Motor
USBsetup; %uses "CompressionSpeed" and creates analogoutput object "ao"

%Prep Camera
%Number of vertical images, we want the same real distance to pixel ratio
%as for the horizontal direction to reconstruct 3d volumes.
imacount = floor(scan_distance/pixel_width);
%Standard glvar setup and opening of camera
glvar = struct('do_libunload',0,'do_close',0,'camera_open',0,'out_ptr',[]);
[err,glvar] = pco_camera_open_close(glvar);
pco_errdisp('pco_camera_setup',err);
%standard camera startup
enable_timestamp(glvar.out_ptr,2);
set_pixelrate(glvar.out_ptr,1);
start_camera(glvar.out_ptr);
set_exposure_time(glvar.out_ptr,exposure_time, 2);
time_per_frame = show_frametime(glvar.out_ptr);
if(~libisloaded('GRABFUNC'))
    loadlibrary('grabfunc','grabfunc.h','alias','GRABFUNC');
end

%Calculate Motor Parameters for Forward Motion
% Overall
abort_decel = 20; %in rps^2
% Lasers
laser_forward_rpm = floor(pixel_width*(1/time_per_frame)*(60/85));
laser_forward_rpm = min(80,laser_forward_rpm); %limit maxium speed to 80 RPM (11.3 cm per second)
laser_forward_targetlocation = floor(scan_distance*(50000/85)); %location in microsteps. As set in the proprietary program, CME 2, 0 is at the negitave limt switch and there are 50,000 microsteps per revolution (85mm)
far_laser_forward_targetlocation = laser_forward_targetlocation;
near_laser_forward_targetlocation = laser_forward_targetlocation;
laser_forward_accel = 10; %in rps^2
laser_forward_decel = 10; %in rps^2
% Camera
camera_forward_rpm = floor((1/refraction_index)*laser_forward_rpm); %use refractive index to calcuate camera speed
camera_forward_targetlocation = floor((1/refraction_index)*laser_forward_targetlocation);
camera_forward_accel = 10;
camera_forward_decel = 10;

% Calculate Reverse Motor Parameters
% Lasers
laser_back_rpm = 20; %about 2.8 cm per second
far_laser_back_targetlocation = 0; %negative limit
near_laser_back_targetlocation = 0; %negative limit +3900steps
laser_back_accel = 10; %in rps^2
laser_back_decel = 10; %in rps^2
% Camera
camera_back_rpm = 20;
camera_back_targetlocation = 0;
camera_back_accel = 10;
camera_back_decel = 10;

%execute series of scans
tic
for scanNumber = 1:numberOfScans
%Save parameters to motor controllers
motorparam(s1,laser_forward_rpm,laser_forward_accel,laser_forward_decel,abort_decel);
motorparam(s3,laser_forward_rpm,laser_forward_accel,laser_forward_decel,abort_decel);
motorparam(s2,camera_forward_rpm,camera_forward_accel,camera_forward_decel,abort_decel);

%Move lasers
moveto(s1,near_laser_forward_targetlocation)
moveto(s3,far_laser_forward_targetlocation)
%Move Camera
moveto(s2,camera_forward_targetlocation)


%Take Pictures
if(err == 0)
    [err,image_stack,glvar] = pco_get_live_image(imacount,glvar);
end
pause(20); %this pause makes the motors move properly...figure out what is causing it to not wait for the motors to move?
%Save reverse parameters to laser controllers

motorparam(s1,laser_back_rpm,laser_back_accel,laser_back_decel,abort_decel);
motorparam(s3,laser_back_rpm,laser_back_accel,laser_back_decel,abort_decel);
motorparam(s2,camera_back_rpm,camera_back_accel,camera_back_decel,abort_decel);

% Move lasers
moveto(s1,near_laser_back_targetlocation);
moveto(s3,far_laser_back_targetlocation);
% Move camera
moveto(s2,camera_back_targetlocation);
%Move Compression cell
moveWall(motionSeries(scanNumber), ao);
%take note of the time motor motion started
motionStartTime = cputime;
picnum=scanNumber;
%Make a new folder for the images in this 3D scan
currentScanName = [scanFolderName, num2str(picnum, '%03.0f'), '/'];
mkdir(target_folder, currentScanName);

%Adjust and Save images
if(err == 0)
    for n = 1:length(image_stack(1,1,:)) %Don't save bad bottom images
        disp(['Currently saving image number: ',num2str(n)]);
        ima = image_stack(:,:,n)'; %contrast adjust and invert the image, turned off
        ima = ima(682:1525, 784:1637); %crop image before saving (y1:y2,x1:x2)
        filename = [target_folder, currentScanName, ImgName, num2str(n, '%03.0f'), Extension];
        imwrite(ima,filename,'Compression','deflate'); %save image to folder
    end
end
clear ima;
clear image_stack;

%wait for long enough for the motors to move
timeNeeded = max(abs(motionSeries(scanNumber))/CompressionSpeed, 7);
timeSinceMotorStart = max(cputime - motionStartTime, 0);
pause((timeNeeded - timeSinceMotorStart));

%Reinitialise motors every 50 scans, what for?
if mod(scanNumber,50) == 0
    motorclose;
    pause(2);
    motorsetup;
end
toc
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

clear;

%Inform of completion
msg = msgbox('Thy will hast been done as thou hast commanded.','Scan Complete');