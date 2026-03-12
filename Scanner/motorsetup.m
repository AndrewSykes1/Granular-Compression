% Near Laser
s1=serial('COM5');
fopen(s1);

% Camera
s2=serial('COM2');
fopen(s2);

% Far Laser
s3=serial('COM1');
fopen(s3);

% Establish stepper mode
fprintf(s1,'s r0x24 31 \n;');
fprintf(s2,'s r0x24 31 \n;');
fprintf(s3,'s r0x24 31 \n;');

% Set movement to absolute movement with trapezoidal profile
fprintf(s1,'s r0xc8 0 \n;');
fprintf(s2,'s r0xc8 0 \n;');
fprintf(s3,'s r0xc8 0 \n;');