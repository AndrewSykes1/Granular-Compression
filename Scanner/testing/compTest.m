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
RevVelocity = compVelocity*10.0; %The wall now moves 0.1" per revolution.
RevACDE = RevVelocity*10;

display(RevVelocity);

% Command strings to set max's
velCommand = strcat('VE',num2str(RevVelocity));
accCommand = strcat('AC',num2str(RevACDE));
dccCommand = strcat('DE',num2str(RevACDE));

% Send commands
writeline(s4,velCommand); 
writeline(s4,accCommand); 
writeline(s4,dccCommand); 
writeline(s4,'EG51200'); 

%Make data to send
compStep = -200000;
Command=strcat('FL',num2str(compStep));
writeline(s4,Command);

pause(.2);
flush(s4);
writeline(s4, 'SC');  % Input Status
dog = char(readline(s4));
display(class(dog));

fprintf('%s\n',dog(6));