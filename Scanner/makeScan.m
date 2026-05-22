
% Take data for each cross section
for imgNumber = 1:imgCount
    
    % Save frame to stack
    frame = getdata(vid,1); 
    imgStack(:,:,imgNumber) = frame;

    % Move lasers and camera
    moveto(s1,-round(motorTargets(imgNumber),0));
    moveto(s3, round(motorTargets(imgNumber),0));
    moveto(s2, round(motorTargets(imgNumber),0));

    % Wait for motors to finish moving
    finishMove(s1);
    finishMove(s3);
    finishMove(s2);

    % Flush mid-motion images
    flushdata(vid);
end

% Save odd scans
if mod(scanNumber,2) == 1 
    saveHDF5(imgStack, scanNumber, experimentFolder);
end








