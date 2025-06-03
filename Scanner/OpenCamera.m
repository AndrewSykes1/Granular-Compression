function [errorCode,glvar,out_ptr,bitpix,act_xsize,act_ysize,sBufNr,temp_image,ev_ptr,im_ptr]=OpenCamera(glvar)
%Open camera before each scan

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


ph_ptr = libpointer('voidPtrPtr');

%libcall PCO_OpenCamera
if(cam_open==0)
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_OpenCamera', ph_ptr, 0);
 if(errorCode == 0)
  disp('PCO_OpenCamera done');
  cam_open=1;
  if((exist('glvar','var'))&& ...
     (isfield(glvar,'camera_open'))&& ...
     (isfield(glvar,'out_ptr')))
   glvar.camera_open=1;
   glvar.out_ptr=out_ptr;
  end 
 else
   pco_errdisp('PCO_OpenCamera',errorCode);   
  if(unload)
   unloadlibrary('PCO_CAM_SDK');
   disp('PCO_CAM_SDK unloadlibrary done');
  end 
  return ;   
 end
else
 if(isfield(glvar,'out_ptr'))
  out_ptr=glvar.out_ptr;   
 end
end


%get Camera Description
%ml_cam_desc.wSize=uint16(getstructsize('PCO_Description'));
cam_desc=libstruct('PCO_Description');
set(cam_desc,'wSize',cam_desc.structsize);

[errorCode,out_ptr,cam_desc] = calllib('PCO_CAM_SDK', 'PCO_GetCameraDescription', out_ptr,cam_desc);
pco_errdisp('PCO_GetCameraDescription',errorCode);   

%set bitalignment LSB
bitalign=uint16(1);
[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetBitAlignment', out_ptr,bitalign);
pco_errdisp('PCO_SetBitAlignment',errorCode);

bitpix=uint16(cam_desc.wDynResDESC);


act_xsize=uint16(0);
act_ysize=uint16(0);
max_xsize=uint16(0);
max_ysize=uint16(0);
%use PCO_GetSizes because this always returns accurat image size for next recording
[errorCode,out_ptr,act_xsize,act_ysize]  = calllib('PCO_CAM_SDK', 'PCO_GetSizes', out_ptr,act_xsize,act_ysize,max_xsize,max_ysize);
pco_errdisp('PCO_GetSizes',errorCode);   

[errorCode,out_ptr]  = calllib('PCO_CAM_SDK', 'PCO_CamLinkSetImageParameters', out_ptr,act_xsize,act_ysize);
if(errorCode)
 pco_errdisp('PCO_CamLinkSetImageParameters',errorCode);   
 return;
end


%--------------------------------------------------------------------------
%Next follow stuff copied from pco_get_image_single
%--------------------------------------------------------------------------

act_recstate = uint16(10); 
[errorCode,out_ptr,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState', out_ptr,act_recstate);
pco_errdisp('PCO_GetRecordingState',errorCode);   

%get the memory for the images
%need special code for firewire interface
imas=uint32(fix((double(bitpix)+7)/8));
imas= imas*uint32(act_ysize)* uint32(act_xsize); 
imasize=imas;

temp_image=ones(act_xsize,act_ysize,'uint16');

sBufNr=int16(-1);
im_ptr = libpointer('uint16Ptr',temp_image);
ev_ptr = libpointer('voidPtr');

[errorCode,out_ptr,sBufNr,temp_image,ev_ptr]  = calllib('PCO_CAM_SDK','PCO_AllocateBuffer', out_ptr,sBufNr,imasize,im_ptr,ev_ptr);
if(errorCode)
 pco_errdisp('PCO_AllocateBuffer',errorCode);   
 return;
end

if(act_recstate==0)
 disp('Start Camera and grab image')   
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr,1);
 pco_errdisp('PCO_SetRecordingState',errorCode);   
end 

end