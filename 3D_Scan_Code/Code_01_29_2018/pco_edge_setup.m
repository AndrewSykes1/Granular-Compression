function [errorCode,glvar] = pco_edge_setup(set_default,glvar)
%
%   [errorCode,glvar] = pco_camera_setup(glvar)
%
%	* Input parameters :
%		struct     glvar
%	* Output parameters :
%                  errorCode
%       struct     glvar
%
%does setup of camera, change any parameters as needed
%binning, roi, exposuretime, triggermode ...
%
%structure glvar is used to set different modes for
%load/unload library
%open/close camera SDK
%
%glvar.do_libunload: 1 unload lib at end
%glvar.do_close:     1 close camera SDK at end
%glvar.camera_open:  open status of camera SDK
%glvar.out_ptr:      libpointer to camera SDK handle
%
%if glvar does not exist,
%the library is loaded at begin and unloaded at end
%the SDK is opened at begin and closed at end
%
%function workflow
%camera recording is stopped
%parameters are set
%camera is armed
%errorCode and if available glvar is returned
%
%remark:
%the camera will hold all parameters until power is switched off
%or new settings will be sent
%
%internal used variables to setup camera
%if one of the variables does not exist, camera default setting is used
%the following variables are just main parameters
%for other parameters see camera and SDK manual
%
%PixelRate: select one of the values in the camera descriptor
%           1: lowest Rate first value of descriptor
%           2: highest Rate second value of descriptor 
%         3,4: not available at the moment   
PixelRate=2; 

%TimeStamp:
%           0: no timestamp
%           1: only binary timestamp
%           2: binary and ASCII Timestamp
%           3: only ASCII Timestamp
TimeStamp=2;


%ROI: select region of interest, the given values are for binning 1x1 
%     if binning is set to other values, new ROI values are calculated
%     if DualADC is selected, the horizontal ROI must be symetric
%     stepping of roi values depends on camera model, see descriptor
%     roi_x1, roi_x2 range is from 1 to maximal horizontal resolution of camera
%     roi_y1, roi_y2 range is from 1 to maximal vertical resolution of camera
%     the following values set a ROI of 1024 pixel x 512 lines in the center of a pco.2000 camera
%     see also ROI calculation before ROI setting
%roi_x1=uint16(1);
%roi_x2=uint16(1536);
%roi_y1=uint16(1);
%roi_y2=uint16(1280);

%Binning: select horizontal and/or vertical binning on the pixels
%         stepping of binning values depends on camera model, see descriptor
%         the following values set no binning 
bin_x=uint16(1);
bin_y=uint16(1);

%Trigger: select trigger mode of camera
%            0: TRIGGER_MODE_AUTOTRIGGER    
%            1: TRIGGER_MODE_SOFTWARETRIGGER
%            2: TRIGGER_MODE_EXTERNALTRIGGER
%            3: TRIGGER_MODE_EXTERNALEXPOSURECONTROL:
trigger=uint16(0);

%Timebase and times: set time and timebase for delay and exposure times
%Timebase:
%            0: TIMEBASE ns
%            1: TIMEBASE µs
%            2: TIMEBASE ms
%Delay and Exposure time: range of values depends on camera model, see descriptor 
%                         the following values set no Delay and 10ms exposure time
del_timebase=uint32(2);
del_time=uint32(0);
exp_timebase=uint32(2);
exp_time=uint32(10);



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

if(~exist('set_default','var'))
 set_default=1;   
end


%Declaration of variable CameraHandle 
%out_ptr is the CameraHandle, which must be used in all other libcalls
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

%test camera recording state and stop camera, if camera is recording
act_recstate = uint16(0); 
[errorCode,out_ptr,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState', out_ptr,act_recstate);
pco_errdisp('PCO_GetRecordingState',errorCode);   

if(act_recstate~=0)
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr, 0);
 pco_errdisp('PCO_SetRecordingState',errorCode);   
end

%if set_default is set, reset camera to default values
if(set_default==1)
 disp('Set camera to default values')   
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_ResetSettingsToDefault', out_ptr);
 pco_errdisp('PCO_ResetSettingsToDefault',errorCode);   
end

%get Camera Description
cam_desc=libstruct('PCO_Description');
set(cam_desc,'wSize',cam_desc.structsize);

[errorCode,out_ptr,cam_desc] = calllib('PCO_CAM_SDK', 'PCO_GetCameraDescription', out_ptr,cam_desc);
pco_errdisp('PCO_GetCameraDescription',errorCode);   

%set PixelRate for Sensor
if(exist('PixelRate','var'))
 if(cam_desc.dwPixelRateDESC(PixelRate))
  [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetPixelRate', out_ptr,cam_desc.dwPixelRateDESC(PixelRate));
  pco_errdisp('PCO_SetPixelRate',errorCode);   
 end
end

%set Timestamp 
if(exist('TimeStamp','var'))
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetTimestampMode', out_ptr,TimeStamp);
 pco_errdisp('PCO_SetTimesatmpMode',errorCode);   
end

%calculation of Roi with horizontal and vertical size as input
%calculation can be used
%horizontal_Size=uint16(800);
%vertical_Size=uint16(600);
horizontal_Size=uint16(cam_desc.wMaxHorzResStdDESC);
vertical_Size=uint16(cam_desc.wMaxVertResStdDESC);
center_roi_x1=(uint16(cam_desc.wMaxHorzResStdDESC)-horizontal_Size)/2;
center_roi_x2=uint16(cam_desc.wMaxHorzResStdDESC)-center_roi_x1;
center_roi_x1=center_roi_x1+1;
center_roi_y1=(uint16(cam_desc.wMaxVertResStdDESC)-vertical_Size)/2;
center_roi_y2=uint16(cam_desc.wMaxVertResStdDESC)-center_roi_y1;
center_roi_y1=center_roi_y1+1;

%set ROI 
if((~exist('roi_x1','var'))||(~exist('roi_x2','var'))||(~exist('roi_y1','var'))||(~exist('roi_y2','var')))
 roi_x1=uint16(center_roi_x1);
 roi_x2=uint16(center_roi_x2);
 roi_y1=uint16(center_roi_y1);
 roi_y2=uint16(center_roi_y2);
end   

a=roi_y2-(roi_y1-1);
if(a+(2*(roi_y1-1))~=cam_desc.wMaxVertResStdDESC)
 disp('Y-ROI setting not symetric correct it');   
 roi_y2=cam_desc.wMaxVertResStdDESC-(2*(roi_y1-1));
end 

[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetROI', out_ptr,roi_x1,roi_y1,roi_x2,roi_y2);
pco_errdisp('PCO_SetROI',errorCode);   

[errorCode,out_ptr,roi_x1,roi_y1,roi_x2,roi_y2] = calllib('PCO_CAM_SDK', 'PCO_GetROI', out_ptr,roi_x1,roi_y1,roi_x2,roi_y2);
pco_errdisp('PCO_GetROI',errorCode);   

disp(['PCO_ROI ',int2str(roi_x1),' ',int2str(roi_x2),' ',int2str(roi_y1),' ',int2str(roi_y2),' ',]);   

%set binning 
if((exist('bin_x','var'))&&(exist('bin_y','var')))
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetBinning', out_ptr,bin_x,bin_y);
 pco_errdisp('PCO_SetBinning',errorCode);   
end

[errorCode,out_ptr,bin_x,bin_y] = calllib('PCO_CAM_SDK', 'PCO_GetBinning', out_ptr,bin_x,bin_y);
pco_errdisp('PCO_GetBinning',errorCode);   

%must adapt ROI to binning
if((bin_x>1)||(bin_y>1))
 if(roi_x1>1)   
  roi_x1=((roi_x1-1)/bin_x)+1;
 end
 if(roi_y1>1)
  roi_y1=((roi_y1-1)/bin_y)+1;
 end
 roi_x2=roi_x2/bin_x;
 roi_y2=roi_y2/bin_y;

 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetROI', out_ptr,roi_x1,roi_y1,roi_x2,roi_y2);
 pco_errdisp('PCO_SetROI',errorCode);   
end

%set trigger
if(exist('trigger','var'))
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetTriggerMode', out_ptr,trigger);
 pco_errdisp('PCO_SetTriggerMode',errorCode);   
end


%set delay and exposure time  
if((exist('del_timebase','var'))&&(exist('del_time','var'))&&(exist('exp_timebase','var'))&&(exist('exp_time','var')))
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetDelayExposureTime', out_ptr,del_time,exp_time,del_timebase,exp_timebase);
 pco_errdisp('PCO_PCO_SetDelayExposureTime',errorCode);   
end

clear cam_desc;    

[errorCode] = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', out_ptr);
pco_errdisp('PCO_ArmCamera',errorCode);   

act_xsize=uint16(0);
act_ysize=uint16(0);
max_xsize=uint16(0);
max_ysize=uint16(0);
%use PCO_GetSizes because this always returns accurat image size for next recording
[errorCode,out_ptr,act_xsize]  = calllib('PCO_CAM_SDK', 'PCO_GetSizes', out_ptr,act_xsize,act_ysize,max_xsize,max_ysize);
pco_errdisp('PCO_GetSizes',errorCode);   

pixelrate=uint32(0);
[errorCode,out_ptr,pixelrate]  = calllib('PCO_CAM_SDK', 'PCO_GetPixelRate',out_ptr,pixelrate);
pco_errdisp('PCO_GetPixelRate',errorCode);   

clpar=uint32(zeros(1,5));
%%get size of variable clpar
%s=whos('clpar');
%len=s.bytes;
%clear s;
len=5*4;


[errorCode,out_ptr,clpar] = calllib('PCO_CAM_SDK', 'PCO_GetTransferParameter', out_ptr,clpar,len);
pco_errdisp('PCO_GetTransferParameter',errorCode);   
disp('Actual transfer parameter')
disp(['baudrate:      ',num2str(clpar(1))]);
disp(['ClockFrequency ',num2str(clpar(2))]);
disp(['CCline         ',num2str(clpar(3))]);
disp(['Dataformat     ',num2str(clpar(4),'%08X')]);
disp(['Transmit       ',num2str(clpar(5),'%08X')]); 

lut=uint16(0);
par=uint16(0);
clpar(1)=115200;
if((pixelrate>286000)&&(act_xsize>1920))
%fast and high resolution use PCO_CL_DATAFORMAT_5x12L 
 a=bitand(clpar(4),hex2dec('FF00'));   
 clpar(4)=a+9;   
 lut=hex2dec('1612');
else
%normal use PCO_CL_DATAFORMAT_5x16    
 a=bitand(clpar(4),255);   
 clpar(4)=a+5;   
end    

[errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetTransferParameter', out_ptr,clpar,len);
pco_errdisp('PCO_SetTransferParameter',errorCode);   

[errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetActiveLookupTable', out_ptr,lut,par);
pco_errdisp('SetActiveLookupTable',errorCode);   

[errorCode] = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', out_ptr);
pco_errdisp('PCO_ArmCamera',errorCode);   

[errorCode,out_ptr,clpar] = calllib('PCO_CAM_SDK', 'PCO_GetTransferParameter', out_ptr,clpar,len);
pco_errdisp('PCO_GetTransferParameter',errorCode);   
disp('Actual transfer parameter now')
disp(['baudrate:      ',num2str(clpar(1))]);
disp(['ClockFrequency ',num2str(clpar(2))]);
disp(['CCline         ',num2str(clpar(3))]);
disp(['Dataformat     ',num2str(clpar(4),'%08X')]);
disp(['Transmit       ',num2str(clpar(5),'%08X')]); 


%get time in ms, which is used for one image
dwSec=uint32(0);
dwNanoSec=uint32(0);
[errorCode,out_ptr,dwSec,dwNanoSec] = calllib('PCO_CAM_SDK', 'PCO_GetCOCRuntime', out_ptr,dwSec,dwNanoSec);
pco_errdisp('PCO_GetCOCRuntime',errorCode);   

waittime_s = double(dwNanoSec);
waittime_s = waittime_s / 1000000000;
waittime_s = waittime_s + double(dwSec);

fprintf(1,'one frame needs %6.6fs, maximal frequency %6.3fHz',waittime_s,1/waittime_s);
disp(' ');

if((do_close==1)&&(cam_open==1))
 [errorCode] = calllib('PCO_CAM_SDK', 'PCO_CloseCamera', out_ptr);
 if(errorCode)
  pco_errdisp('PCO_CloseCamera ',errorCode);   
 else
  disp('PCO_CloseCamera done');  
  cam_open=0;
  if((exist('glvar','var'))&& ...
    (isfield(glvar,'out_ptr')))
   glvar.out_ptr=[];
  end
 end    
end

if((unload==1)&&(cam_open==0))
 unloadlibrary('PCO_CAM_SDK');
 disp('PCO_CAM_SDK unloadlibrary done');
end 

if((exist('glvar','var'))&& ...
   (isfield(glvar,'camera_open')))
 glvar.camera_open=cam_open;
end

end




