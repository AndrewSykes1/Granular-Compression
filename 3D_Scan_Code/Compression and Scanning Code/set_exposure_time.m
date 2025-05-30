function set_exposure_time(out_ptr,time,timebase)

del_time=uint32(0);
exp_time=uint32(0);
del_base=uint16(0);
exp_base=uint16(0);


[errorCode,~,del_time,~,del_base,~] = calllib('PCO_CAM_SDK', 'PCO_GetDelayExposureTime', out_ptr,del_time,exp_time,del_base,exp_base);
pco_errdisp('PCO_GetDelayExposureTime',errorCode);   

exp_time=uint32(time);
exp_base=uint16(timebase);

[errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetDelayExposureTime', out_ptr,del_time,exp_time,del_base,exp_base);
pco_errdisp('PCO_SetDelayExposureTime',errorCode);   
end