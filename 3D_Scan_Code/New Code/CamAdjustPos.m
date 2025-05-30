pixel_width = 148/441;
refraction_index = 1.49;

laser_forward_rpm = 5;
laser_forward_targetlocation = 53
000;
laser_forward_accel = 10; %in rps^2
laser_forward_decel = 10; %in rps^2

camera_forward_rpm = floor((1/refraction_index)*laser_forward_rpm); %use refractive index to calcuate camera speed
camera_forward_targetlocation = floor((1/refraction_index)*laser_forward_targetlocation);
camera_forward_accel = 10;
camera_forward_decel = 10;

moveto(s1,laser_forward_targetlocation)
moveto(s3,laser_forward_targetlocation)
moveto(s2,camera_forward_targetlocation)