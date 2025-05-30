function edge_test(imacount,waittime)

glvar=struct('do_libunload',0,'do_close',0,'camera_open',0,'out_ptr',[]);

if(~exist('waittime','var'))
 waittime = 0.200;   
end

if(~exist('imacount','var'))
 imacount = 10;   
end


[err,glvar]=pco_camera_open_close(glvar);
pco_errdisp('pco_camera_setup',err); 
disp(['camera_open should be 1 is ',int2str(glvar.camera_open)]);

enable_timestamp(glvar.out_ptr,2);
set_pixelrate(glvar.out_ptr,1);
show_frametime(glvar.out_ptr);
start_camera(glvar.out_ptr);

if(~libisloaded('GRABFUNC'))
 loadlibrary('grabfunc','grabfunc.h','alias','GRABFUNC')
end

if((err==0)&&(imacount<10)) 
 disp(['get',int2str(imacount),'x single image']);
 for n=1:imacount   
  [err,ima,glvar]=pco_get_live_image(1,glvar);
   m=max(max(ima(:,10:end)));
  [xs,ys]=size(ima);
  xmax=600;
  ymax=400;
  if((xs>xmax)&&(ys>ymax))
   ima=ima(1:xmax,1:ymax);
  elseif(xs>xmax)
   ima=ima(1:xmax,:);
  elseif(ys>ymax)
   ima=ima(:,1:ymax);
  end        
  imshow(ima',[0,m+100]);
  if(imacount<=5)
   disp('Press "Enter" to grab next')
   pause();
  else 
   pause(waittime);
  end 
  clear ima;
 end 
 disp('Press "Enter" to close window and proceed')
 pause();
 close();
 pause(1);
end

if((err==0)&&(imacount>5)) 
 disp('get multi images')
 [err,image_stack,glvar]=pco_get_live_image(imacount,glvar);
 if(err==0)
  for n=1:imacount   
   ima=image_stack(:,1:end,n);
   m=max(max(ima(:,10:end)));
   [xs,ys]=size(ima);
   xmax=600;
   ymax=400;
   if((xs>xmax)&&(ys>ymax))
    ima=ima(1:xmax,1:ymax);
   elseif(xs>xmax)
    ima=ima(1:xmax,:);
   elseif(ys>ymax)
    ima=ima(:,1:ymax);
   end        
   imshow(ima',[0,m+100]);
%   imshow(ima(:,:,n)',[0,8000],'InitialMagnification',100);
   if(imacount<20)
    disp('Press "Enter" to show next')
    pause();
   else 
    pause(waittime);
   end 
  end 
 end
 disp('Press "Enter" to close window and camera SDK')
 pause();
 close();
 clear ima;
 clear image_stack;
end


stop_camera(glvar.out_ptr);

calllib('GRABFUNC','pco_edge_transferpar',glvar.out_ptr);

if(libisloaded('GRABFUNC'))
 calllib('GRABFUNC','showhandle',glvar.out_ptr);
 num=uint16(imacount);
 [imastack,num]=calllib('GRABFUNC','pco_imagestack',num,glvar.out_ptr,0);
 %,out_ptr);
 disp([int2str(num),' images allocated and grabbed']);
 for n=1:imacount   
  ima=imastack(:,1:end,n);
  m=max(max(ima(:,10:end)));
  [xs,ys]=size(ima);
  xmax=600;
  ymax=400;
  if((xs>xmax)&&(ys>ymax))
   ima=ima(1:xmax,1:ymax);
  elseif(xs>xmax)
   ima=ima(1:xmax,:);
  elseif(ys>ymax)
   ima=ima(:,1:ymax);
  end        
  print_timestamp(ima,1,16);
  imshow(ima',[0,m+100]);
%   imshow(ima(:,:,n)',[0,8000],'InitialMagnification',100);
  if(imacount<20)
   disp('Press "Enter" to show next')
   pause();
  else 
   pause(waittime);
  end 
 end
 disp('Press "Enter" to close window and camera SDK')
 pause();
 close();
 clear ima;
 clear imastack;
end

stop_camera(glvar.out_ptr);

set_pixelrate(glvar.out_ptr,2);
show_frametime(glvar.out_ptr);
calllib('GRABFUNC','pco_edge_transferpar',glvar.out_ptr);

if(libisloaded('GRABFUNC'))
 num=uint16(imacount);
 [imastack,num]=calllib('GRABFUNC','pco_imagestack',num,glvar.out_ptr,1);
 %,out_ptr);
 disp([int2str(num),' images allocated and grabbed']);
 for n=1:imacount   
  ima=imastack(:,1:end,n);
  m=max(max(ima(:,10:end)));
  [xs,ys]=size(ima);
  xmax=600;
  ymax=400;
  if((xs>xmax)&&(ys>ymax))
   ima=ima(1:xmax,1:ymax);
  elseif(xs>xmax)
   ima=ima(1:xmax,:);
  elseif(ys>ymax)
   ima=ima(:,1:ymax);
  end        
  print_timestamp(ima,1,16);
  imshow(ima',[0,m+100]);
%   imshow(ima(:,:,n)',[0,8000],'InitialMagnification',100);
  if(imacount<20)
   disp('Press "Enter" to show next')
   pause();
  else 
   pause(waittime);
  end 
 end
 disp('Press "Enter" to close window and camera SDK')
 pause();
 close();
 clear ima;
 clear imastack;
end

stop_camera(glvar.out_ptr);

if(libisloaded('GRABFUNC'))
 unloadlibrary('GRABFUNC');
end

if(glvar.camera_open==1)
 glvar.do_close=1;
 glvar.do_libunload=1;
 pco_camera_open_close(glvar);
end   

clear glvar;

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

function start_camera(out_ptr)
act_recstate = uint16(0); 
[errorCode,~,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState', out_ptr,act_recstate);
pco_errdisp('PCO_GetRecordingState',errorCode);   

if(act_recstate~=1)
 [errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr, 1);
 pco_errdisp('PCO_SetRecordingState',errorCode);   
end

end


function stop_camera(out_ptr)

act_recstate = uint16(0); 
[errorCode,~,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState', out_ptr,act_recstate);
pco_errdisp('PCO_GetRecordingState',errorCode);   

if(act_recstate~=0)
 [errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr, 0);
 pco_errdisp('PCO_SetRecordingState',errorCode);   
end

end

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

function show_frametime(out_ptr)

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

function enable_timestamp(out_ptr,Stamp)

act_recstate = uint16(0); 
[errorCode,~,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState', out_ptr,act_recstate);
pco_errdisp('PCO_GetRecordingState',errorCode);   

if(act_recstate~=0)
 [errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr, 0);
 pco_errdisp('PCO_SetRecordingState',errorCode);   
end

if((Stamp~=0)&&(Stamp~=1)&&(Stamp~=2)&&(Stamp~=3))
 disp('Stamp must be 0 or 1 or 2 or 3');
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

