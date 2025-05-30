function moveWall(steps, speed)
% establish communication with USB 3103
ao = analogoutput('mcc',0);
% select the voltage output channels that the device will use
VO = addchannel(ao, 0);
V2 = addchannel(ao, 2);
V4 = addchannel(ao, 4);
V6 = addchannel(ao, 6);
%make data to send
data = eye(4);
for i = 2:steps/4
    data = [data ; eye(4)];
end
data = [data; 0 0 0 0];
data = data * 3;
set(ao, 'SampleRate', speed);
putdata(ao, data);
start(ao);
end