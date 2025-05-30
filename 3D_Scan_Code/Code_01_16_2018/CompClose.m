%Disable compression motor and close connection

SendCompCommand(s4,'MD');
fclose(s4);