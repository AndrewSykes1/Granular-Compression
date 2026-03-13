function estimateFinish(dtObj,elapsed,numberOfScans)

estimatedHours = elapsed * 2*numberOfScans/60/60;
newDt = dtObj + hours(estimatedHours);
disp("=-=-=-=-=-=-=-=-=-=-=-=-=-=");
fprintf('Estimated finish in %s hours at %s\n', string(round(estimatedHours,2)), string(newDt));
disp("=-=-=-=-=-=-=-=-=-=-=-=-=-=");

end
