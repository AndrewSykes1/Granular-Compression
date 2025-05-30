function TriggerCamera(out_ptr)
%This command trigger an acquisition of the camera

Triggered=uint16(0);
[errorCode] = calllib('PCO_CAM_SDK', 'PCO_ForceTrigger', out_ptr,Triggered);
if(Triggered==0)
    disp('Could not trigger, camera is busy')
end
pco_errdisp('PCO_ForceTrigger',errorCode);   



end