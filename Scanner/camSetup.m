vid = videoinput('gentl',1,'Mono12Packed');     % Standard glvar setup
vid.ROIPosition = [LoLimX LoLimY Width Height]; % Crop camera

% Trigger settings
vid.TriggerRepeat = Inf;           % Enable continous scanning
vid.FrameGrabInterval = 1;         % Store only every 5th frame

% Obtain source
vid_src = getselectedsource(vid);
vid_src.Tag = 'particle image';

% Binning by addition
vid_src.BinningHorizontal = 2;    % Horizontal pixel addition
vid_src.BinningVertical = 2;      % Verticle pixel addition

% Set gain
vid_src.GainAuto = 'Off';
vid_src.Gain = 0;

% Start camera
start(vid);
vid_src = getselectedsource(vid);

% Set exposure settings                            
vid_src.ExposureAuto = "Off";
vid_src.ExposureTime = exposure_time*1000;  % Set exposure time in microseconds
time_per_frame = exposure_time;             % Find time to obtain each frame