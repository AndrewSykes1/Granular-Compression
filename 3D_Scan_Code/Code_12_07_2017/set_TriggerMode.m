function set_TriggerMode(out_ptr,trigger)
%This function set the trigger mode of the camera: 0 auto, 1 software,
%etc...

%test camera recording state and stop camera, if camera is recording
act_recstate = uint16(0); 
[errorCode,~,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState', out_ptr,act_recstate);
pco_errdisp('PCO_GetRecordingState',errorCode);   

if(act_recstate~=0)
 [errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr, 0);
 pco_errdisp('PCO_SetRecordingState',errorCode);   
end 

if((trigger~=0)&&(trigger~=1)&&(trigger~=2)&&(trigger~=3)...
        &&(trigger~=4)&&(trigger~=5)&&(trigger~=6)&&(trigger~=7))
 disp('Trigger mode must be between 0 and 7');
 return;
end 
 
%set thet trigger mode
exp_trigger=uint16(trigger);
[errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetTriggerMode', out_ptr,exp_trigger);
pco_errdisp('PCO_SetTriggerMode',errorCode);   


%Restore recording state
[errorCode] = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', out_ptr);
pco_errdisp('PCO_ArmCamera',errorCode);   

if(act_recstate~=0)
 [errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr, act_recstate);
 pco_errdisp('PCO_SetRecordingState',errorCode);   
end

end