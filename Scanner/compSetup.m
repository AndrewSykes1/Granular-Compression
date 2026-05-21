% Open serial connection
s4=serialport(compCom,9600,'DataBits',8, 'Parity','none','StopBits',1);
configureTerminator(s4,"CR");

% Activate motor
writeline(s4,'HR'); % Establish connection
writeline(s4,'AR'); % Reset alarm
writeline(s4,'ME'); % Enable motor

% Compute Vel:[rev/s] and Acc:[rev/s^2]
ustepVelo = compVelocity*compConv;
ustepACDE = ustepVelo*10;

% Command strings to set max's
velCommand = strcat('VE',num2str(ustepVelo));
accCommand = strcat('AC',num2str(ustepACDE));
dccCommand = strcat('DE',num2str(ustepACDE));

% Send commands
writeline(s4,velCommand); 
writeline(s4,accCommand); 
writeline(s4,dccCommand); 
writeline(s4,'EG51200');