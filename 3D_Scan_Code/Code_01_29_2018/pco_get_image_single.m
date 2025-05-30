function [errorCode,temp_image,out_ptr] = pco_get_image_single(out_ptr,act_xsize,act_ysize,bitpix,sBufNr,temp_image,ev_ptr,im_ptr)


[errorCode,out_ptr]  = calllib('PCO_CAM_SDK','PCO_GetImageEx',out_ptr,1,0,0,sBufNr,act_xsize,act_ysize,bitpix);


[errorCode,out_ptr,temp_image]  = calllib('PCO_CAM_SDK','PCO_GetBuffer',out_ptr,sBufNr,im_ptr,ev_ptr);


end