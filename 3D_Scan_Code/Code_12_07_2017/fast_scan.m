 %Start laser scanning
    for imageNumber = 1:imacount

        %Take one frame
        %if(err == 0)
        %    [err,image_stack(:,:,imageNumber),glvar] = pco_get_live_image_ROI(glvar,784,1637,682,1525);
        %end

        
        %Move lasers and camera
        moveto(s1,laser_forward_targetlocation)
        moveto(s3,laser_forward_targetlocation)
        moveto(s2,camera_forward_targetlocation)
        
        %Set next position
        laser_forward_targetlocation=laser_forward_step+laser_forward_targetlocation;
        camera_forward_targetlocation=camera_forward_step+camera_forward_targetlocation;
        
        
    end %end laser scan