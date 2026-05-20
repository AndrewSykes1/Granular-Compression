% Connect to motors
s1=serial(nearLaserCom); fopen(s1); % Near Laser
s2=serial(cameraCom);    fopen(s2); % Camera
s3=serial(farLaserCom);  fopen(s3); % Far Laser

% Establish stepper mode
fprintf(s1,'s r0x24 31 \n;');
fprintf(s2,'s r0x24 31 \n;');
fprintf(s3,'s r0x24 31 \n;');

% Set movement to absolute with trapezoidal profile
fprintf(s1,'s r0xc8 0 \n;'); % This means halfway along the
fprintf(s2,'s r0xc8 0 \n;'); % track is position 80,000, and
fprintf(s3,'s r0xc8 0 \n;'); % to get there you say go 80000
