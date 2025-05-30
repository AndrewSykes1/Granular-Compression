%This program executes a full scan of the 3D subject

%Input Parameters For Scan Calculations
container_size = 80; %in mm
pixel_width = 150/457/2; %in mm
refraction_index = 1.49; %used to calculate relative speed of camera and laser motors
exposure_time = 10; %in ms
%Input Save Settings
target_folder = 'E:\PowersCooper\TestScans\test\';
ImgName = 'Image';
Extension = '.tif';

%Prep Motors
motorsetup;

%Prep Camera
imacount = floor(container_size/pixel_width);
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
laser_forward_targetlocation = floor(container_size*(50000/85)); %location in microsteps. As set in the proprietary program, CME 2, 0 is at the negitave limt switch and there are 50,000 microsteps per revolution (85mm)
laser_forward_accel = 10; %in rps^2
laser_forward_decel = 10; %in rps^2
% Camera
camera_forward_rpm = floor((1/refraction_index)*laser_forward_rpm); %use refractive index to calcuate camera speed
camera_forward_targetlocation = floor((1/refraction_index)*laser_forward_targetlocation);
camera_forward_accel = 10;
camera_forward_decel = 10;

%Save parameters to motor controllers
%motorparam(s1,laser_forward_rpm,laser_forward_accel,laser_forward_decel,abort_decel);
motorparam(s3,laser_forward_rpm,laser_forward_accel,laser_forward_decel,abort_decel);
motorparam(s2,camera_forward_rpm,camera_forward_accel,camera_forward_decel,abort_decel);

%Move lasers
%moveto(s1,laser_forward_targetlocation)
moveto(s3,laser_forward_targetlocation)
%Move Camera
moveto(s2,camera_forward_targetlocation)

%Take Pictures
if(err == 0)
    [err,image_stack,glvar] = pco_get_live_image(imacount,glvar);
end

% Set Reverse Parameters
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

%Save reverse parameters to laser controllers
%motorparam(s1,laser_back_rpm,laser_back_accel,laser_back_decel,abort_decel);
motorparam(s3,laser_back_rpm,laser_back_accel,laser_back_decel,abort_decel);
motorparam(s2,camera_back_rpm,camera_back_accel,camera_back_decel,abort_decel);

% Move lasers
%moveto(s1,laser_back_targetlocation);
moveto(s3,laser_back_targetlocation);
% Move camera
moveto(s2,camera_back_targetlocation);

%Adjust and Save images
if(err == 0)
    for n = 1:length(image_stack(1,1,:))
        ima = image_stack(:,1:end,n)'; %contrast adjust and invert the image, turned off
        filename = [target_folder, ImgName, num2str(n), Extension];
        imwrite(ima,filename); %save image to folder
    end
end
clear ima;
clear image_stack;

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
msg = msgbox('The operation has been completed as directed.','Scan Complete');