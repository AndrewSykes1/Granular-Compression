% Near Laser
s1=serial('COM2');
fopen(s1);

% % Camera
s2=serial('COM7');
fopen(s2);

% % Far Laser
s3=serial('COM1');
fopen(s3);

% establish stepper mode
fprintf(s1,'s r0x24 31 \n;');
fprintf(s2,'s r0x24 31 \n;');
fprintf(s3,'s r0x24 31 \n;');

% set movement mode:
% 0,1-absolute trap, absolute s-curve
% 256,257-relative trap, relative s-curve
fprintf(s1,'s r0xc8 0 \n;');
fprintf(s2,'s r0xc8 0 \n;');
fprintf(s3,'s r0xc8 0 \n;');