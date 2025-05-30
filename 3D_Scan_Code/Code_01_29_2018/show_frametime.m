function waittime_s=show_frametime(out_ptr)

%get time in ms, which is used for one image
dwSec=uint32(0);
dwNanoSec=uint32(0);
[errorCode,~,dwSec,dwNanoSec] = calllib('PCO_CAM_SDK', 'PCO_GetCOCRuntime', out_ptr,dwSec,dwNanoSec);
pco_errdisp('PCO_GetCOCRuntime',errorCode);   

waittime_s = double(dwNanoSec);
waittime_s = waittime_s / 1000000000;
waittime_s = waittime_s + double(dwSec);

fprintf(1,'one frame needs %6.6fs, maximal frequency %6.3fHz',waittime_s,1/waittime_s);
disp(' ');

end