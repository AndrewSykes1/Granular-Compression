fprintf("Currently in Scan %d\n",scanNumber);
fprintf("Current stack dims: (%d,%d,%d)\n", size(imgStack));

% Take data for each cross section
for imgNumber = 1:imgCount
        
        % Save frame to stack
        frame = getdata(vid,1); 
        imgStack(:,:,imgNumber) = frame(:,:,:,1);

        % Move lasers and camera
        moveto(s1,-motorTargets(imgNumber));
        moveto(s3, motorTargets(imgNumber));
        moveto(s2, motorTargets(imgNumber));
        
        % Wait for movement
        fprintf('%.2f\n',motorTargets(imgNumber));
        fprintf('%.4f\n',motorTargets(2)/(motorForwardRpm*8333)*10);
        pause(motorTargets(2)/(motorForwardRpm*8333)*10+.5);
        fprintf('Gap\n');
     
end

% Save odd scans
if mod(scanNumber,2) == 1 
    saveHDF5(imgStack, scanNumber, experimentFolder);
end








