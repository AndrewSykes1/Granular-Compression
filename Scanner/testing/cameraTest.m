delete(instrfindall); close all;
clear s1 s2 s3 s4 vid vid_src;
imaqreset;

% General
volLen     = 6.5;  % Length (in) of volume compressed
volHeight  = 3.45; % Height (in) of volume's liquid
totalScans = 100;   % Number of scans       

% Camera
LoLimX=0; Width  = 1216;
LoLimY=0; Height = 1024;
exposureTime = 50;  % Exposure time (ms)
imgCount     = 1000;  % Number of images in stack
imgStack = zeros(Height, Width, imgCount, 'uint16');

vid = videoinput('gentl',1,'Mono12Packed');     % Standard glvar setup
vid.ROIPosition = [LoLimX LoLimY Width Height]; % Crop camera

% Trigger settings
vid.TriggerRepeat = Inf;   % Enable continuous scanning

% Obtain source
vid_src = getselectedsource(vid);
vid_src.Tag = 'particle image';

% Binning by addition
vid_src.BinningHorizontal = 2;    % Horizontal pixel addition
vid_src.BinningVertical = 2;      % Vertical pixel addition

% Set gain
vid_src.GainAuto = 'Off';
vid_src.Gain = 0;

% Start camera
start(vid);
vid_src = getselectedsource(vid);

% Set exposure settings                            
vid_src.ExposureAuto = "Off";
vid_src.ExposureTime = exposureTime*1000;  % Set exposure time in microseconds
time_per_frame = exposureTime;             % Find time to obtain each frame

% Show Video
disp(preview(vid));
