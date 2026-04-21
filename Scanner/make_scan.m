% Take data for each cross section
fprintf("Currently in Scan %d\n",scanNumber);
fprintf("Current stack dims: (%d,%d,%d)\n", size(image_stack));
for imageNumber = 1:imageCount
        
        %Take one frame
        frame = getdata(vid,1);
        image_stack(:,:,imageNumber) = frame(:,:,:,1);
        
        %Move lasers and camera
        moveto(s1,motorTargets(imageNumber))
        moveto(s3,motorTargets(imageNumber))
        moveto(s2,motorTargets(imageNumber)) 
end








