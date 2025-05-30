%This program executes a full scan of the 3D subject

%Input Parameters For Scan Calculations
scan_distance = 140; %in mm
pixel_width = 148/441; %in mm
refraction_index = 1.49; %used to calculate relative speed of camera and laser motors
exposure_time = 40; %in ms

%Input Parameters for compression cell motion
CompressionSpeed = 50; % speed in steps per second (max 100)
CompressionPercent=1;
motionSeries = CompressionPercent*[((floor(mod((1:160) - 1, 16)/8)*-2+1)*120)' ; ((floor(mod((1:1520) - 1, 4)/2)*-2+1)*480)'; ((floor(mod((1:160) - 1, 16)/8)*-2+1)*120)' ;0]; %compression cell motion series (in steps) 800 steps = 1/20 in
%motionSeries = 0;
numberOfScans = length(motionSeries);

%Input Save Settings
target_folder = 'F:\DataRun_111715\';
scanFolderName = 'Scan';
ImgName = 'Image';
Extension = '.tif';

%Prep Laser and Camera Motors
motorsetup; %creates serial objects s1, s2, s3 (s1 currently commented out)

%Prep Compression Cell Motor
USBsetup; %uses "CompressionSpeed" and creates analogoutput object "ao"

%Prep Camera
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
laser_back_targetlocation = 0; %negative limit
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
moveto(s1,laser_forward_targetlocation)
moveto(s3,laser_forward_targetlocation)
%Move Camera
moveto(s2,camera_forward_targetlocation)

%Take Pictures
if(err == 0)
    [err,image_stack,glvar] = pco_get_live_image(imacount,glvar);
end

%Save reverse parameters to laser controllers
motorparam(s1,laser_back_rpm,laser_back_accel,laser_back_decel,abort_decel);
motorparam(s3,laser_back_rpm,laser_back_accel,laser_back_decel,abort_decel);
motorparam(s2,camera_back_rpm,camera_back_accel,camera_back_decel,abort_decel);

% Move lasers
moveto(s1,laser_back_targetlocation);
moveto(s3,laser_back_targetlocation);
% Move camera
moveto(s2,camera_back_targetlocation);
%Move Compression cell
moveWall(motionSeries(scanNumber), ao);
%take note of the time motor motion started
motionStartTime = cputime;

%Make a new folder for the images in this 3D scan
currentScanName = [scanFolderName, num2str(scanNumber, '%03.0f'), '/'];
mkdir(target_folder, currentScanName);

%Adjust and Save images
if(err == 0)
    for n = 1:length(image_stack(1,1,:))
        ima = image_stack(:,:,n)'; %contrast adjust and invert the image, turned off
        ima = ima(95:595,165:665); %crop image before saving (y1:y2,x1:x2)
        filename = [target_folder, currentScanName, ImgName, num2str(n, '%03.0f'), Extension];
        imwrite(ima,filename); %save image to folder
    end
end
clear ima;
clear image_stack;

%wait for long enough for the motors to move
timeNeeded = max(abs(motionSeries(scanNumber))/CompressionSpeed, 7);
timeSinceMotorStart = max(cputime - motionStartTime, 0);
pause(timeNeeded - timeSinceMotorStart);

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
msg = msgbox('Thy will hath been done as thou hast commanded.','Scan Complete');