% Near Laser
s1=serialport('COM5',9600);


% % Camera
s2=serialport('COM2',9600);


% % Far Laser
s3=serialport('COM1',9600);


% establish stepper mode
writeline(s1,'s r0x24 31 \n;');
writeline(s2,'s r0x24 31 \n;');
writeline(s3,'s r0x24 31 \n;');

% set movement mode:
% 0,1-absolute trap, absolute s-curve
% 256,257-relative trap, relative s-curve
writeline(s1,'s r0xc8 0 \n;');
writeline(s2,'s r0xc8 0 \n;');
writeline(s3,'s r0xc8 0 \n;');