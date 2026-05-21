clear all;
delete(instrfindall);

volHeight = 5.00; % Height (in) of volume's liquid
imgCount  = 10;   % Number of images in stack

% LaseCam Motors
motorTargets = linspace(1,volHeight*12800,imgCount); % [12800u/in]
motorForwardRpm = 8;   motorReverseRpm = 20;  % Forward vel (rpm)
motorForwardAcc = 40;  motorReverseAcc = 10;  % Forward acc (rps^2)
motorForwardDcc = 40;  motorReverseDcc = 10;  % Forward dcc (rps^2)
motorHome = 0;         motorAbortDcc   = 50;  

% Setup Motors %
nearLaserCom = 'COM5'; camCom  = 'COM2';
farLaserCom  = 'COM1'; compCom = 'COM4';

motorSetup; % Create s1:Near, s2:Camera, s3:Far

% Set to reverse
motorparam(s1, motorReverseRpm, motorReverseAcc, motorReverseDcc, motorAbortDcc);
motorparam(s3, motorReverseRpm, motorReverseAcc, motorReverseDcc, motorAbortDcc);
motorparam(s2, motorReverseRpm, motorReverseAcc, motorReverseDcc, motorAbortDcc);

% Move to position 0
moveto(s1, motorHome);
moveto(s3, motorHome);
moveto(s2, motorHome);

pause(5);

% Set to forward
motorparam(s1, motorForwardRpm, motorForwardAcc, motorForwardDcc, motorAbortDcc);
motorparam(s3, motorForwardRpm, motorForwardAcc, motorForwardDcc, motorAbortDcc);
motorparam(s2, motorForwardRpm, motorForwardAcc, motorForwardDcc, motorAbortDcc);

% Move to position
pos = 40000;
moveto(s1, -pos);
moveto(s3, pos);
moveto(s2, pos);

dt = pos/(motorForwardRpm*8333)*10;
fprintf('Waiting %.2f seconds.\n',dt);
pause(dt);
fprintf('Finished\n');

% Move to position 0
moveto(s1, motorHome);
moveto(s3, motorHome);
moveto(s2, motorHome);