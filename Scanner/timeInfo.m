% Show scan start time
if scanNumber == 1
    
    % Print message
    dt = datetime('now','TimeZone','local','Format','HH:mm:ss');
    disp('+=========================+');
    fprintf('Beginning scan at %s\n', dt);
    disp('+=========================+');

    tic;
end

% Show scan finish time
if scanNumber == 2

    % Estimate hours till completion
    estimatedHours = toc*totalScans/60/60;
    newDt = dt + hours(estimatedHours);
    
    % Print message
    finishTime = string(newDt);
    totalTime  = string(round(estimatedHours,2)); 
    disp("+-----------------------------------------+");
    fprintf('Estimated finish in %s hours at %s\n', totalTime, finishTime);
    disp("+-----------------------------------------+");

end