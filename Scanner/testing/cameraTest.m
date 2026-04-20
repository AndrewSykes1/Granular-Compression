delete(instrfindall); close all;
clear s1 s2 s3 s4 vid vid_src;
imaqreset;

  % 50ms for exposure time

% Image capture region
LoLimX=0;
LoLimY=0;
Width = 1224;
Height = 1024;   

%% Config Camera %%
vid = videoinput('gentl',1,'Mono12Packed');     % Standard glvar setup
vid.ROIPosition = [LoLimX LoLimY Width Height]; % Crop camera

% Trigger settings
vid.TriggerRepeat = Inf;           % Enable continous scanning
vid.FrameGrabInterval = 1;         % Store only every 5th frame

% Obtain source
vid_src = getselectedsource(vid);
vid_src.Tag = 'particle image';

% Pooling by addition
vid_src.BinningHorizontal = 2;    % Horizontal pixel addition
vid_src.BinningVertical = 2;      % Verticle pixel addition

% Set gain
vid_src.GainAuto = 'Off';
vid_src.Gain = 0;

% Start camera
start(vid);
vid_src = getselectedsource(vid);

exposure_time = 50; %ms 
% Set exposure settings                            
vid_src.ExposureAuto = "Off";
vid_src.ExposureTime = exposure_time*1000;  % Set exposure time in microseconds
time_per_frame = exposure_time;             % Find time to obtain each frame
disp('Camera configured')

preview(vid);

fprintf("Attempted Framerate: %.2f", vid_src.AcquisitionFrameRate);

%get(vid_src);
%propinfo(vid_src);

imageNumber = 0;
while true
    %Take one frame

    get(vid, 'FramesAvailable');
    getdata(vid,1);
    imageNumber = imageNumber + 1;
end