function [errorCode,image_stack,glvar] = pco_get_live_image_ROI(glvar,x1,x2,y1,y2)
%Return only a limited ROI of the full image
%
%   [errorCode,glvar,image_stack] = pco_get_image(glvar,first_image,imacount)
%
%	* Input parameters :
%		struct     glvar
%                  first_image
%                  imacount
%	* Output parameters :
%                  errorCode
%       struct     glvar
%       uint16(,,) image_stack
%
%does readout of 'imacount' images from the internal memory of the pco.camera 
%into the labview array image_stack starting from number 'first_image' 
%if 'first_image' is set to '0' and camera is recording, live images are
%readout
%
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
%if imacount does not exist, it is set to '1'
%
%function workflow
%parameters are checked
%Alignment for the image data is set to LSB
%the size of the images is readout from the camera
%labview array is build
%allocate buffer(s) in camera SDK 
%to readout single images PCO_GetImageEx function is used
%to readout multiple images
%PCO_AddBufferEx and PCO_WaitforBuffer functions are used in a loop
%free previously allocated buffer(s) in camera SDK 
%errorCode, if available glvar, and the image_stack with uint16 image data is returned
%



% Declaration of internal variables

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
bytepix=fix(double(bitpix+7)/8);

cam_type=libstruct('PCO_CameraType');
set(cam_type,'wSize',cam_type.structsize);

[errorCode,out_ptr,cam_type] = calllib('PCO_CAM_SDK', 'PCO_GetCameraType', out_ptr,cam_type);
pco_errdisp('PCO_GetCameraType',errorCode);   

interface=uint16(cam_type.wInterfaceType);


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

[errorCode,image_stack] = pco_get_image_single(out_ptr,act_xsize,act_ysize,bitpix,interface);

%Trim to ROI
image_stack=image_stack(x1:x2,y1:y2,:);

pco_errdisp('pco_get_image_...',errorCode);   

glvar = close_camera(out_ptr,unload,do_close,cam_open,glvar);

end

function [errorCode,image_stack] = pco_get_image_single(out_ptr,act_xsize,act_ysize,bitpix,interface)

act_recstate = uint16(10); 
[errorCode,out_ptr,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState', out_ptr,act_recstate);
pco_errdisp('PCO_GetRecordingState',errorCode);   

%get the memory for the images
%need special code for firewire interface
imas=uint32(fix((double(bitpix)+7)/8));
imas= imas*uint32(act_ysize)* uint32(act_xsize); 
imasize=imas;

%only for firewire add always some lines
%to ensure enough memory is allocated for the transfer
if(interface==1)
  i=floor(double(imas)/4096);
  i=i+1;
  i=i*4096;
  imasize=i;
  i=i-double(imas);
  xs=uint32(fix((double(bitpix)+7)/8));
  xs=xs*act_xsize;
  i=floor(i/double(xs));
  i=i+1;
  lineadd=i;

else
 lineadd=0;   
end

image_stack=ones(act_xsize,act_ysize+lineadd,'uint16');

sBufNr=int16(-1);
im_ptr = libpointer('uint16Ptr',image_stack);
ev_ptr = libpointer('voidPtr');

[errorCode,out_ptr,sBufNr,image_stack,ev_ptr]  = calllib('PCO_CAM_SDK','PCO_AllocateBuffer', out_ptr,sBufNr,imasize,im_ptr,ev_ptr);
if(errorCode)
 pco_errdisp('PCO_AllocateBuffer',errorCode);   
 return;
end

if(act_recstate==0)

 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr,1);
 pco_errdisp('PCO_SetRecordingState',errorCode);   
end 



[errorCode,out_ptr]  = calllib('PCO_CAM_SDK','PCO_GetImageEx',out_ptr,1,0,0,sBufNr,act_xsize,act_ysize,bitpix);
if(errorCode)
 pco_errdisp('PCO_GetImageEx',errorCode);   
end

[errorCode,out_ptr,image_stack]  = calllib('PCO_CAM_SDK','PCO_GetBuffer',out_ptr,sBufNr,im_ptr,ev_ptr);
pco_errdisp('PCO_GetBuffer',errorCode);   

for n=1:lineadd
% disp(['delete ',int2str(n), '. line at end']);
 image_stack(:,end)=[];
end

if(act_recstate==0)
 disp('Stop Camera')   
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr,0);
 pco_errdisp('PCO_SetRecordingState',errorCode);   
end 


errorCode  = calllib('PCO_CAM_SDK','PCO_FreeBuffer',out_ptr,sBufNr);
pco_errdisp('PCO_FreeBuffer',errorCode);   

clear ev_ptr;

end

function [errorCode,image_stack] = pco_get_image_multi(out_ptr,imacount,act_xsize,act_ysize,bitpix,interface)

if(imacount<2)
 disp('Wrong image count, must be 2 or greater, return')    
 errorCode=hex2int('A0004001');
 return;
end

act_recstate = uint16(10); 
[errorCode,out_ptr,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState', out_ptr,act_recstate);
pco_errdisp('PCO_GetRecordingState',errorCode);   


%get the memory for the images
%need special code for firewire interface
imas=uint32(fix((double(bitpix)+7)/8));
imas= imas*uint32(act_xsize)* uint32(act_ysize); 
imasize=imas;

%only for firewire
if(interface==1)
  i=floor(double(imas)/4096);
  i=i+1;
  i=i*4096;
  imasize=i;
  i=i-double(imas);
  xs=uint32(fix((double(bitpix)+7)/8));
  xs=xs*act_xsize;
  i=floor(i/double(xs));
  i=i+1;
  lineadd=i;
else
 lineadd=0;   
end

image_stack=ones(act_xsize,(act_ysize+lineadd),imacount,'uint16');

%Allocate 2 SDK buffer and set address of buffers in stack
sBufNr_1=int16(-1);
im_ptr_1 = libpointer('uint16Ptr',image_stack(:,:,1));
ev_ptr_1 = libpointer('voidPtr');

[errorCode,out_ptr,sBufNr_1,image_stack(:,:,1),ev_ptr_1]  = calllib('PCO_CAM_SDK','PCO_AllocateBuffer', out_ptr,sBufNr_1,imasize,im_ptr_1,ev_ptr_1);
if(errorCode)
 pco_errdisp('PCO_AllocateBuffer',errorCode);   
 return;
end

sBufNr_2=int16(-1);
im_ptr_2 = libpointer('uint16Ptr',image_stack(:,:,2));
ev_ptr_2 = libpointer('voidPtr');

[errorCode,out_ptr,sBufNr_2,image_stack(:,:,2),ev_ptr_2]  = calllib('PCO_CAM_SDK','PCO_AllocateBuffer', out_ptr,sBufNr_2,imasize,im_ptr_2,ev_ptr_2);
if(errorCode)
 pco_errdisp('PCO_AllocateBuffer',errorCode);   
 err  = calllib('PCO_CAM_SDK','PCO_FreeBuffer',out_ptr,sBufNr_1);
 pco_errdisp('PCO_FreeBuffer',err);   
 return;
end
disp(['bufnr1: ',int2str(sBufNr_1),' bufnr2: ',int2str(sBufNr_2)]);
ml_buflist_1.sBufNr=sBufNr_1;
buflist_1=libstruct('PCO_Buflist',ml_buflist_1);
ml_buflist_2.sBufNr=sBufNr_2;
buflist_2=libstruct('PCO_Buflist',ml_buflist_2);

disp(['bufnr1: ',int2str(buflist_1.sBufNr),' bufnr2: ',int2str(buflist_2.sBufNr)]);

if(act_recstate==0)
 disp('Start Camera and grab image')   
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr,1);
 pco_errdisp('PCO_SetRecordingState',errorCode);   
end 

[errorCode,out_ptr]  = calllib('PCO_CAM_SDK','PCO_AddBufferEx', out_ptr,0,0,sBufNr_1,act_xsize,act_ysize,bitpix);
pco_errdisp('PCO_AddBufferEx',errorCode);   
 
[errorCode,out_ptr]  = calllib('PCO_CAM_SDK','PCO_AddBufferEx', out_ptr,0,0,sBufNr_2,act_xsize,act_ysize,bitpix);
pco_errdisp('PCO_AddBufferEx',errorCode);   

for n=1:imacount
% s='';
 if(rem(n,2)==1)
%  disp(['Wait for buffer 1 n: ',int2str(n)]);   
  [errorCode,out_ptr,buflist_1]  = calllib('PCO_CAM_SDK','PCO_WaitforBuffer', out_ptr,1,buflist_1,500);
  if(errorCode)
   pco_errdisp('PCO_WaitforBuffer 1',errorCode);   
   break;
  end 
%  disp(['statusdll: ',num2str(buflist_1.dwStatusDll,'%08X'),' statusdrv: ',num2str(buflist_1.dwStatusDrv,'%08X')]);   
  if((bitand(buflist_1.dwStatusDll,hex2dec('00008000')))&&(buflist_1.dwStatusDrv==0))
%   s=strcat(s,'Event buf_1, image ',int2str(n),' done, StatusDrv ',num2str(buflist_1.dwStatusDrv,'%08X'));
  %this will copy our data to image_stack
   [errorCode,out_ptr,image_stack(:,:,n)]  = calllib('PCO_CAM_SDK','PCO_GetBuffer',out_ptr,sBufNr_1,im_ptr_1,ev_ptr_1);
   if(errorCode)
    pco_errdisp('PCO_GetBuffer',errorCode);   
    break;
   end 
   
   buflist_1.dwStatusDll= bitand(buflist_1.dwStatusDll,hex2dec('FFFF7FFF'));
   if(n+2<=imacount)
    im_ptr_1 = libpointer('uint16Ptr',image_stack(:,:,n+2));
    [errorCode,out_ptr,sBufNr_1,image_stack(:,:,n+2),ev_ptr_1]  = calllib('PCO_CAM_SDK','PCO_AllocateBuffer', out_ptr,sBufNr_1,imasize,im_ptr_1,ev_ptr_1);
    if(errorCode)
     pco_errdisp('PCO_AllocateBuffer',errorCode);   
     break; 
    end
    [errorCode,out_ptr]  = calllib('PCO_CAM_SDK','PCO_AddBufferEx', out_ptr,0,0,sBufNr_1,act_xsize,act_ysize,bitpix);
    if(errorCode)
     pco_errdisp('PCO_AddBufferEx',errorCode);   
     break;
    end
%   s=strcat(s,' set in queue again');
   end
%   disp(s);
  end
 else 
%  disp(['Wait for buffer 2 n: ',int2str(n)]);   
  [errorCode,out_ptr,buflist_2]  = calllib('PCO_CAM_SDK','PCO_WaitforBuffer', out_ptr,1,buflist_2,500);
  if(errorCode)
   pco_errdisp('PCO_WaitforBuffer 2',errorCode);   
   break;
  end 
%  disp(['statusdll: ',num2str(buflist_2.dwStatusDll,'%08X'),' statusdrv: ',num2str(buflist_2.dwStatusDrv,'%08X')]);   
  if(bitand(buflist_2.dwStatusDll,hex2dec('00008000'))&&(buflist_2.dwStatusDrv==0))
%   s=strcat(s,'Event buf_2, image ',int2str(n),' done, StatusDrv ',num2str(buflist_2.dwStatusDrv,'%08X'));
  %this will copy our data to image_stack
   [errorCode,out_ptr,image_stack(:,:,n)]  = calllib('PCO_CAM_SDK','PCO_GetBuffer',out_ptr,sBufNr_2,im_ptr_2,ev_ptr_2);
   if(errorCode)
    pco_errdisp('PCO_GetBuffer',errorCode);   
    break;
   end
   buflist_2.dwStatusDll= bitand(buflist_2.dwStatusDll,hex2dec('FFFF7FFF'));
   if(n+2<=imacount)
    im_ptr_2 = libpointer('uint16Ptr',image_stack(:,:,n+2));
    [errorCode,out_ptr,sBufNr_2,image_stack(:,:,n+2),ev_ptr_2]  = calllib('PCO_CAM_SDK','PCO_AllocateBuffer', out_ptr,sBufNr_2,imasize,im_ptr_2,ev_ptr_2);
    if(errorCode)
     pco_errdisp('PCO_AllocateBuffer',errorCode);   
     break; 
    end
    [errorCode,out_ptr]  = calllib('PCO_CAM_SDK','PCO_AddBufferEx', out_ptr,0,0,sBufNr_2,act_xsize,act_xsize,bitpix);
    if(errorCode)
     pco_errdisp('PCO_AddBufferEx',errorCode);   
     break;
    end
%    s=strcat(s,' set in queue again');
   end 
%   disp(s);
  end
 end
end

for m=1:lineadd
 image_stack(:,end,:)=[];
end


%this will remove all pending buffers in the queue
[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_CancelImages', out_ptr);
pco_errdisp('PCO_CancelImages',errorCode);   

if(act_recstate==0)
 disp('Stop Camera')   
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr,0);
 pco_errdisp('PCO_SetRecordingState',errorCode);   
end 

%free buffers
errorCode  = calllib('PCO_CAM_SDK','PCO_FreeBuffer',out_ptr,sBufNr_1);
pco_errdisp('PCO_FreeBuffer',errorCode);   
   
errorCode  = calllib('PCO_CAM_SDK','PCO_FreeBuffer',out_ptr,sBufNr_2);
pco_errdisp('PCO_FreeBuffer',errorCode);   

end
function time=print_timestamp(ima,act_align,bitpix)

%ts=zeros(14,1,'double');  
if(act_align==0)
 ts=fix(double(ima(1:14,1))/(2^(16-bitpix)));   
else
 ts=double(ima(1:14,1));  
end

b='';
b=[b,int2str(fix(ts(1,1)/16)),int2str(bitand(ts(1,1),15))];
b=[b,int2str(fix(ts(2,1)/16)),int2str(bitand(ts(2,1),15))];
b=[b,int2str(fix(ts(3,1)/16)),int2str(bitand(ts(3,1),15))];
b=[b,int2str(fix(ts(4,1)/16)),int2str(bitand(ts(4,1),15))];

b=[b,' '];
%year
b=[b,int2str(fix(ts(5,1)/16)),int2str(bitand(ts(5,1),15))];   
b=[b,int2str(fix(ts(6,1)/16)),int2str(bitand(ts(6,1),15))];   
b=[b,'-'];
%month
b=[b,int2str(fix(ts(7,1)/16)),int2str(bitand(ts(7,1),15))];   
b=[b,'-'];
%day
b=[b,int2str(fix(ts(8,1)/16)),int2str(bitand(ts(8,1),15))];   
b=[b,' '];

%hour   
c=[int2str(fix(ts(9,1)/16)),int2str(bitand(ts(9,1),15))];   
b=[b,c,':'];
time=str2double(c)*60*60;
%min   
c=[int2str(fix(ts(10,1)/16)),int2str(bitand(ts(10,1),15))];   
b=[b,c,':'];
time=time+(str2double(c)*60);
%sec   
c=[int2str(fix(ts(11,1)/16)),int2str(bitand(ts(11,1),15))];   
b=[b,c,'.'];
time=time+str2double(c);
%us   
c=[int2str(fix(ts(12,1)/16)),int2str(bitand(ts(12,1),15))];   
b=[b,c];
time=time+(str2double(c)/100);
c=[int2str(fix(ts(13,1)/16)),int2str(bitand(ts(13,1),15))];   
b=[b,c];
time=time+(str2double(c)/10000);
c=[int2str(fix(ts(14,1)/16)),int2str(bitand(ts(14,1),15))];   
b=[b,c];
time=time+(str2double(c)/1000000);
disp(b)
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