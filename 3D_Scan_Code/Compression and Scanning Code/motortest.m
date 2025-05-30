%This program executes a full scan of the 3D subject

%Input Parameters For Scan Calculations
scan_distance = 76; %in mm
pixel_width = 148/878; %in mm
refraction_index = 1.49; %used to calculate relative speed of camera and laser motors
exposure_time = 50; %in ms

%Prep Laser and Camera Motors
motorsetup; %creates serial objects s1, s2, s3 (s1 currently commented out)
time_per_frame = 0.05;
numberOfScans = 30;

%Calculate Motor Parameters for Forward Motion
% Overall
abort_decel = 20; %in rps^2
% Lasers
laser_forward_rpm = 20; %limit maxium speed to 80 RPM (11.3 cm per second)
laser_forward_targetlocation = 110000; %location in microsteps. As set in the proprietary program, CME 2, 0 is at the negitave limt switch and there are 50,000 microsteps per revolution (85mm)
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

for scanNumber = 1:numberOfScans
disp(scanNumber);
%Save parameters to motor controllers
motorparam(s1,laser_forward_rpm,laser_forward_accel,laser_forward_decel,abort_decel);
motorparam(s3,laser_forward_rpm,laser_forward_accel,laser_forward_decel,abort_decel);
motorparam(s2,camera_forward_rpm,camera_forward_accel,camera_forward_decel,abort_decel);

%Move lasers
moveto(s1,laser_forward_targetlocation)
moveto(s3,laser_forward_targetlocation)
%Move Camera
moveto(s2,camera_forward_targetlocation)
pause (5)
%Save reverse parameters to laser controllers
motorparam(s1,laser_back_rpm,laser_back_accel,laser_back_decel,abort_decel);
motorparam(s3,laser_back_rpm,laser_back_accel,laser_back_decel,abort_decel);
motorparam(s2,camera_back_rpm,camera_back_accel,camera_back_decel,abort_decel);

% Move lasers
moveto(s1,laser_back_targetlocation);
moveto(s3,laser_back_targetlocation);
% Move camera
moveto(s2,camera_back_targetlocation);
%take note of the time motor motion started
pause(5)
if mod(scanNumber,50) == 0
    motorclose;
    pause(2);
    motorsetup;
end
end

%Motor Shutdown
motorclose;

clear;

%Inform of completion
msg = msgbox('Thy will hath been done as thou hast commanded.','Scan Complete');