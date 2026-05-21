% Connect to motors
s1=serial(nearLaserCom); fopen(s1); % Near Laser
s2=serial(camCom);    fopen(s2); % Camera
s3=serial(farLaserCom);  fopen(s3); % Far Laser

% Establish stepper mode
fprintf(s1,'s r0x24 31 \n;');
fprintf(s2,'s r0x24 31 \n;');
fprintf(s3,'s r0x24 31 \n;');

% Use absolute movement w/trapezoidal profile
fprintf(s1,'s r0xc8 0 \n;');
fprintf(s2,'s r0xc8 0 \n;');
fprintf(s3,'s r0xc8 0 \n;');
