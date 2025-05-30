%clear
%Prep motors
%motorsetup

%Place forward Parameters

% Overall
abort_decel=20;
% Lasers
l_f_rpm=20;
l_f_distance=100000;
l_f_accel=10;
l_f_decel=10;
% Camera
c_f_rpm=10;
c_f_distance=50000;
c_f_accel=10;
c_f_decel=10;

laserparam(s1,l_f_rpm,l_f_accel,l_f_decel,abort_decel);
laserparam(s3,l_f_rpm,l_f_accel,l_f_decel,abort_decel);
laserparam(s2,c_f_rpm,c_f_accel,c_f_decel,abort_decel);

% Move motors
moveto(s1,l_f_distance)
moveto(s3,l_f_distance)
moveto(s2,c_f_distance)

%Camera Operation

% Wait
pause(7)

% Set Reverse Parameters
% Lasers
l_b_rpm=20;
l_b_distance=0;
l_b_accel=10;
l_b_decel=10;
% Camera
c_b_rpm=10;
c_b_distance=0;
c_b_accel=10;
c_b_decel=10;

laserparam(s1,l_b_rpm,l_b_accel,l_b_decel,abort_decel);
laserparam(s3,l_b_rpm,l_b_accel,l_b_decel,abort_decel);
laserparam(s2,c_b_rpm,c_b_accel,c_b_decel,abort_decel);


% Move lasers
moveto(s1,l_b_distance)
moveto(s3,l_b_distance)
moveto(s2,c_b_distance)

% Wait
pause(7)

%motorclose

% Inform of completion
msg=msgbox('The operation has been completed as directed.','Scan Complete');