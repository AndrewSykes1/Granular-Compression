delete(instrfindall);
clear s1 s2 s3 s4;
imaqreset;


nearLaserCom = 'COM5'; cameraCom = 'COM2';
farLaserCom  = 'COM1'; compCom   = 'COM4';
s1=serial('COM1');
fopen(s1);



% Establish stepper mode
fprintf(s1,'s r0x24 31 \n;');

% Set movement to absolute movement with trapezoidal profile
fprintf(s1,'s r0xc8 0 \n;');

motorReverseRpm = 20;
motorReverseAcc = 10;
motorReverseDcc = 10; 
abort_decel     = 50;
motorparam(s1, motorReverseRpm,  motorReverseAcc,  motorReverseDcc,  abort_decel);

usteps=0;
fprintf(s1, sprintf('s r0xca %d \n;', usteps));
fprintf(s1, 't 1 \n;');

% Move to position (usteps)


