function [glvar]=CloseCamera(glvar,out_ptr,ev_ptr,sBufNr)
%Close camera after each scan

%--------------------------------------------------------------------------
%Next follow stuff copied from pco_get_image_single
%--------------------------------------------------------------------------

act_recstate = uint16(10); 
[errorCode,out_ptr,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState', out_ptr,act_recstate);
pco_errdisp('PCO_GetRecordingState',errorCode);   

if(act_recstate==0)
 disp('Stop Camera')   
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr,0);
 pco_errdisp('PCO_SetRecordingState',errorCode);   
end 


errorCode  = calllib('PCO_CAM_SDK','PCO_FreeBuffer',out_ptr,sBufNr);
pco_errdisp('PCO_FreeBuffer',errorCode);   

clear ev_ptr;

%--------------------------------------------------------------------------

% Test if library is loaded
if (~libisloaded('PCO_CAM_SDK'))
    % make sure the dll and h file specified below resides in your current
    % folder
	loadlibrary('SC2_Cam','SC2_CamMatlab.h' ...
                ,'addheader','SC2_CamExport.h' ...
                ,'alias','PCO_CAM_SDK');
	disp('PCO_CAM_SDK library is loaded!');
end

if((exist('glvar','var'))&& ...
   (isfield(glvar,'do_libunload'))&& ...
   (isfield(glvar,'do_close'))&& ...
   (isfield(glvar,'camera_open'))&& ...
   (isfield(glvar,'out_ptr')))
 unload=glvar.do_libunload;    
 cam_open=glvar.camera_open;
 do_close=glvar.do_close;
else
 unload=1;   
 cam_open=0;
 do_close=1;
end

if(exist('glvar','var'))
 glvar = close_camera(out_ptr,unload,do_close,cam_open,glvar);
else
 close_camera(out_ptr,unload,do_close,cam_open);   
end

end

function [glvar] = close_camera(out_ptr,unload,do_close,cam_open,glvar)
 if((do_close==1)&&(cam_open==1))
  errorCode = calllib('PCO_CAM_SDK', 'PCO_CloseCamera',out_ptr);
  if(errorCode)
   pco_errdisp('PCO_CloseCamera',errorCode);   
  else
   disp('PCO_CloseCamera done');
   cam_open=0;
   if((exist('glvar','var'))&& ...
      (isfield(glvar,'camera_open'))&& ...
      (isfield(glvar,'out_ptr')))
    glvar.out_ptr=[];
    glvar.camera_open=0;
   end
  end    
 end
 if((unload==1)&&(cam_open==0))
  unloadlibrary('PCO_CAM_SDK');
  disp('PCO_CAM_SDK unloadlibrary done');
 end 
end