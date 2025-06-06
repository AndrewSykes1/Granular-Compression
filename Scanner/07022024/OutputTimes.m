function OutputTimes(ElapsedTime,scanNumber,numberOfScans)
%This function display time since the begining of the simulation and 
%estimated time to finish.

disp(['Elapsed time is: ',secs2hms(ElapsedTime)]);

EstimatedTime=ElapsedTime/scanNumber*numberOfScans-ElapsedTime;

disp(['Estimated time to finish is: ',secs2hms(EstimatedTime)]);

end

function time_string=secs2hms(time_in_secs)
    time_string='';
    nhours = 0;
    nmins = 0;
    if time_in_secs >= 3600
        nhours = floor(time_in_secs/3600);
        if nhours > 1
            hour_string = ' hours, ';
        else
            hour_string = ' hour, ';
        end
        time_string = [num2str(nhours) hour_string];
    end
    if time_in_secs >= 60
        nmins = floor((time_in_secs - 3600*nhours)/60);
        if nmins > 1
            minute_string = ' mins, ';
        else
            minute_string = ' min, ';
        end
        time_string = [time_string num2str(nmins) minute_string];
    end
    nsecs = time_in_secs - 3600*nhours - 60*nmins;
    time_string = [time_string sprintf('%2.1f', nsecs) ' secs'];
end