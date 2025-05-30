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
CompressionDistance = 3.0;
CompressionSteps    = floor(CompressionDistance / in2mm * Inch2Step);
% -------------------------------------------------------------------------

%Prep Compression Cell Motor
CompSetup; %uses "CompressionSpeed" and creates serial object s4

%Calculate Motor Parameters for Forward Motion
% Overall
abort_decel = 50; %in rps^2


%execute series of scans
tic
for scanNumber = 1
    disp(['Cycle: ',num2str(scanNumber)]);
    for sign = -1
        %Do things intelegently, move motors, triger camera, move motors,
        %triger camera, etc...
        %Save parameters to motor controllers



        %Move Compression cell
        disp(['Wall Counter: ',num2str(scanNumber)]);
        disp(['Moving wall: ',num2str(CompressionSteps)]);
        moveWall(sign*CompressionSteps,s4);

        %take note of the time motor motion started
        motionStartTime = cputime;



        %wait for long enough for the motors to move
        timeNeeded = CompressionDistance/CompressionSpeed;
        disp(['Required time: ',num2str(timeNeeded),' seconds?']);
        timeSinceMotorStart = max(cputime - motionStartTime, 0);
        disp(timeNeeded - timeSinceMotorStart + 2);
        pause((timeNeeded - timeSinceMotorStart + 2));

        %Estimate times
        ElapsedTime=toc;
        OutputTimes(ElapsedTime,scanNumber,1);
    end
end


CompClose;

%Clear and close everything
close all;

%Inform of completion
msg = msgbox('Thy will hast been done as thou hast commanded.','Scan Complete');