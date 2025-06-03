function enable_timestamp(out_ptr,Stamp)

act_recstate = uint16(0); 
[errorCode,~,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState', out_ptr,act_recstate);
pco_errdisp('PCO_GetRecordingState',errorCode);   

if(act_recstate~=0)
 [errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr, 0);
 pco_errdisp('PCO_SetRecordingState',errorCode);   
end

if((Stamp~=0)&&(Stamp~=1)&&(Stamp~=2))
 disp('Stamp must be 0 or 1 or 2');
 return;
end

[errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetTimestampMode', out_ptr,Stamp);
pco_errdisp('PCO_SetTimestampMode',errorCode);   

[errorCode] = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', out_ptr);
pco_errdisp('PCO_ArmCamera',errorCode);   

if(act_recstate~=0)
 [errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr, act_recstate);
 pco_errdisp('PCO_SetRecordingState',errorCode);   
end


end