clear all;

% Compression Motor
compVelocity = 2;  % Speed of compression (in/s)
compPercent  = .10;  % Percent of container to compress

% Open serial connection
compCom = 'COM4';
s4=serialport(compCom,9600,'DataBits',8, 'Parity','none','StopBits',1);
configureTerminator(s4,"CR");

% Activate motor
writeline(s4,'HR'); % Establish connection
writeline(s4,'AR'); % Reset alarm
writeline(s4,'ME'); % Enable motor

% Compute Vel:[rev/s] and Acc:[rev/s^2]
RevVelocity = compVelocity*10.0/(25.4); %The wall now moves 0.1" per revolution.
RevACDE = RevVelocity*10;

% Command strings to set max's
velCommand = strcat('VE',num2str(RevVelocity));
accCommand = strcat('AC',num2str(RevACDE));
dccCommand = strcat('DE',num2str(RevACDE));

% Send commands
writeline(s4,velCommand); 
writeline(s4,accCommand); 
writeline(s4,dccCommand); 
writeline(s4,'EG51200'); %Set the microstepping resolution to the maximum
%of 51200 microsteps per revolution or 256 
%microsteps per real step. The
%real motor resolution is 200 steps per
%revolution, i.e. 1.8 deg per step. 

%Make data to send
compStep = -100000;
Command=strcat('FL',num2str(compStep));
writeline(s4,Command);