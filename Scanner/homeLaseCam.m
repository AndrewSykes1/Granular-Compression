motorparam(s1, laser_back_rpm,  laser_back_accel,  laser_back_decel,  abort_decel);
motorparam(s3, laser_back_rpm,  laser_back_accel,  laser_back_decel,  abort_decel);
motorparam(s2, camera_back_rpm, camera_back_accel, camera_back_decel, abort_decel);
moveto(s1, nearlaser_back_targetlocation);
moveto(s3, farlaser_back_targetlocation);
moveto(s2, camera_back_targetlocation);