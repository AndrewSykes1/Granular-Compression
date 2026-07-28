% Take data for each cross section
for imgNumber = 1:imgCount
     
    % Save frame to stack
    frame = getdata(vid,1); 
    imgStack(:,:,imgNumber) = frame;

    % Move lasers and camera
    moveto(s1,-round(motorTargets(imgNumber)));
    moveto(s2, round(motorTargets(imgNumber)));
    moveto(s3, round(motorTargets(imgNumber)));

    % Wait for motors to finish moving
    finishLCMove(s1);
    finishLCMove(s2);
    finishLCMove(s3);

    % Flush mid-motion images
    flushdata(vid);
end

% Save scans
subCycleNum = i;
saveHDF5(imgStack, cycleNumber, subCycleNum,  experimentFolder);









