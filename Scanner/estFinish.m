if scanNumber == minNumberOfScans & cycleNum == minNumberOfCycles

    elapsedTime = toc;
    estimatedHours = elapsedTime * 2*numberOfScans/60/60;
    newDt = dt + hours(estimatedHours);

    disp("+-----------------------------------------+");
    fprintf('Estimated finish in %s hours at %s\n', string(round(estimatedHours,2)), string(newDt));
    disp("+-----------------------------------------+");
    
end