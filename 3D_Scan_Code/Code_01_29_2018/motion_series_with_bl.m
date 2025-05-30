function motionSeries=motion_series_with_bl(num_cycles,comp_dist,backlash_dist)
%This function compute the motion serie for the wall, taking into account
%the backlash of the system.
%For the backlash compensation to work correctly, the system should
%initially be positioned with the motor to have a backslash! I.e., you
%should open(decompress the system with the motor before proceding to the
%experiment)!!!!
%Version 1, AP, July 6 2018.
%--------------------------------------------------------------------------
%
%"num_cycles" is the total number of cycles to make. The first 10 and last
%ten will have 16 scans per cycle, all the other 4 scans per cycle.
%"comp_dist" is the distance to compress in inches.
%"backlash_dist" is the estimated backlash distance.
%--------------------------------------------------------------------------

%Allocate arrays
num_scans=(num_cycles-20)*4+20*16+1;
motionSeries=zeros(num_scans,1);

%Transform distances into steps
backlash_steps=round(wall_inches_to_steps(backlash_dist));
comp_steps=round(wall_inches_to_steps(comp_dist)/16)*16;

%First fill in the 16 scans per cycle at the begining
for c=0:9
    cc=c*16;
    %Compensate the backlash in the first forward motion
    motionSeries(cc+1)=-comp_steps/16-backlash_steps;
    motionSeries(cc+(2:8))=-comp_steps/16;
    %Compensate the backlash in the first backward motion
    motionSeries(cc+9)=comp_steps/16+backlash_steps;
    motionSeries(cc+(10:16))=comp_steps/16;
end

last=10*16;

%Next cycles at 4 scan per cycle
for c=0:num_cycles-21
    cc=last+c*4;
    %Compensate the backlash in the first forward motion
    motionSeries(cc+1)=-comp_steps/4-backlash_steps;
    motionSeries(cc+2)=-comp_steps/4;
    %Compensate the backlash in the first backward motion
    motionSeries(cc+3)=comp_steps/4+backlash_steps;
    motionSeries(cc+4)=comp_steps/4;
end

last=last+(num_cycles-20)*4;

%Finally fill in the 16 scans per cycle at the end
for c=0:9
    cc=last+c*16;
    %Compensate the backlash in the first forward motion
    motionSeries(cc+1)=-comp_steps/16-backlash_steps;
    motionSeries(cc+(2:8))=-comp_steps/16;
    %Compensate the backlash in the first backward motion
    motionSeries(cc+9)=comp_steps/16+backlash_steps;
    motionSeries(cc+(10:16))=comp_steps/16;
end


end