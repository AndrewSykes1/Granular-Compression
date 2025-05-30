function set_pixelrate(out_ptr,Rate)

%test camera recording state and stop camera, if camera is recording
act_recstate = uint16(0); 
[errorCode,~,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState', out_ptr,act_recstate);
pco_errdisp('PCO_GetRecordingState',errorCode);   

if(act_recstate~=0)
 [errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr, 0);
 pco_errdisp('PCO_SetRecordingState',errorCode);   
end

cam_desc=libstruct('PCO_Description');
set(cam_desc,'wSize',cam_desc.structsize);

[errorCode,~,cam_desc] = calllib('PCO_CAM_SDK', 'PCO_GetCameraDescription', out_ptr,cam_desc);
pco_errdisp('PCO_GetCameraDescription',errorCode);   

if((Rate~=1)&&(Rate~=2))
 disp('Rate must be 1 or 2');
 return;
end 
 
%set PixelRate for Sensor
if(cam_desc.dwPixelRateDESC(Rate))
 [errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetPixelRate', out_ptr,cam_desc.dwPixelRateDESC(Rate));
 pco_errdisp('PCO_SetPixelRate',errorCode);   
end

clear cam_desc;    

[errorCode] = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', out_ptr);
pco_errdisp('PCO_ArmCamera',errorCode);   

if(act_recstate~=0)
 [errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr, act_recstate);
 pco_errdisp('PCO_SetRecordingState',errorCode);   
end

end