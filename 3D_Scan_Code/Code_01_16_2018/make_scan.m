%Here make a scan quickly
for imageNumber = 1:imacount

        %Take one frame
        [errorCode,image_stack(:,:,imageNumber),out_ptr] = pco_get_image_single(out_ptr,act_xsize,act_ysize,bitpix,sBufNr,temp_image,ev_ptr,im_ptr,LoLimX,UpLimX,LoLimY,UpLimY);
        %image_stack(:,:,imageNumber)=temp_image(LoLimX:UpLimX,LoLimY:UpLimY)';

        %Move lasers and camera
        moveto(s1,laser_forward_targetlocations(imageNumber))
        moveto(s3,laser_forward_targetlocations(imageNumber))
        moveto(s2,camera_forward_targetlocations(imageNumber))
        
        
end %end laser scan








