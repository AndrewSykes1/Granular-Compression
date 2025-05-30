%Open serial port
s4=serial('COM4','BaudRate',9600,'Terminator','CR','DataBits',8, ...
          'Parity','none','StopBits',1);
fopen(s4);

SendCompCommand(s4,'AR'); %Reset alarm just in case
SendCompCommand(s4,'ME'); %Enable motor

%Compute the velocity in terms of rev per sec
RevVelocity = CompressionSpeed*80.0/(25.4);
Velocity_command = strcat('VE',num2str(RevVelocity));
RevACDE = RevVelocity*10;
Acceleration_command = strcat('AC',num2str(RevVelocity));
Deceleration_command = strcat('DE',num2str(RevVelocity));

SendCompCommand(s4,Acceleration_command); %Set acceleration in rev/sec^2
SendCompCommand(s4,Deceleration_command); %Set deceleration in rev/sec^2
SendCompCommand(s4,Velocity_command); %Set velocity in rev/sec
SendCompCommand(s4,'EG51200'); %Set the microstepping resolution to the maximum
                               %of 51200 microsteps per revolution or 256 
                               %microsteps per real step. The
                               %real motor resolution is 200 steps per
                               %revolution, i.e. 1.8 deg per step. 