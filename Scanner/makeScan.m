fprintf("Currently in Scan %d\n",scanNumber);
fprintf("Current stack dims: (%d,%d,%d)\n", size(imgStack));

% Take data for each cross section
for imgNumber = 1:imgCount

        frame = getdata(vid,1); % Take one frame
        imgStack(:,:,imgNumber) = frame(:,:,:,1);
        
        %Move lasers and camera
        moveto(s1,-motorTargets(imgNumber));
        moveto(s3, motorTargets(imgNumber));
        moveto(s2, motorTargets(imgNumber));
        fprintf('%.1f\n', motorTargets(imgNumber));
        display('dog');
        pause(motorTargets(1)/motorForwardRpm);
        display(motorTargets(1)/motorForwardRpm);
end

% Save odd scans
if mod(scanNumber,2) == 1 
    saveHDF5(imgStack, scanNumber, experimentFolder);
end








