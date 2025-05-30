
% establish communication with USB 3103
ao = analogoutput('mcc',0);
% select the voltage output channels that the device will use
VO = addchannel(ao, 0);
V2 = addchannel(ao, 2);
V4 = addchannel(ao, 4);
V6 = addchannel(ao, 6);
% set motor speed (in steps per second)
set(ao, 'SampleRate', CompressionSpeed);