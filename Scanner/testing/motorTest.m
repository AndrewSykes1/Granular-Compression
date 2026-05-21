delete(instrfindall);
clear s1 s2 s3 s4;
imaqreset;

% Check what serial devices are available
serialportlist("available")

nearLaserCom = 'COM5'; cameraCom = 'COM2';
farLaserCom  = 'COM1'; compCom   = 'COM4';
s1=serial('COM5');
fopen(s1);

fprintf(s1,'s r0x24 31 \n;'); % Use stepper mode
fprintf(s1,'s r0xc8 0 \n;');  % Abs movement w/Trapezoid profile

motorRpm = 20; motorDcc = 10;
motorAcc = 10; abortDcc = 50;
motorparam(s1, motorRpm,  motorAcc,  motorDcc,  abortDcc);

usteps=-80000;
fprintf(s1, sprintf('s r0xca %d \n;', usteps));
fprintf(s1, 't 1 \n;');


