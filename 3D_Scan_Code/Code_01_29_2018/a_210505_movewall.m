%This program moves the compression wall
% -------------------------------------------------------------------------
CompressionSpeed    = 0.10; % In mm per second
% -------------------------------------------------------------------------
% 10 rev      = 1 inch
% 51200 steps = 1 rev 
% 1 inch      = 512,000 steps
Inch2Step  = 512000;
in2mm      = 25.4;
% -------------------------------------------------------------------------
% put in mm
% -------------------------------------------------------------------------
CompressionDistance = 0.5;
CompressionSteps    = floor(CompressionDistance / in2mm * Inch2Step);
nSteps              = 1;
% -------------------------------------------------------------------------
% Prep Compression Cell Motor
% uses "CompressionSpeed" and creates serial object s4
% -------------------------------------------------------------------------
CompSetup;
% -------------------------------------------------------------------------
%Calculate Motor Parameters for Forward Motion
% -------------------------------------------------------------------------
abort_decel = 50; %in rps^2
% -------------------------------------------------------------------------
%execute series of scans
% -------------------------------------------------------------------------
for scanNumber = 1
    fprintf('Cycle %04d\n',scanNumber);
    for sign = -1
        cSteps = floor(CompressionSteps / nSteps);
        cDist  = CompressionDistance / nSteps;
        % Move the compression wall
        moveWall(sign*cSteps,s4);
        %take note of the time motor motion started
        motionStartTime     = cputime;
        timeNeeded          = cDist/CompressionSpeed;
        timeSinceMotorStart = max(cputime - motionStartTime, 0);
        waitTime            = timeNeeded - timeSinceMotorStart + 1;
        fprintf('Moving wall: %i steps, distance is %.2f mm, wait time is %.2f\n'...
            ,cSteps,cDist,waitTime);
        pause(waitTime);
    end
end
%Clear and close everything
CompClose;
close all;
%Inform of completion
msg = msgbox('Thy will hast been done as thou hast commanded.','Scan Complete');