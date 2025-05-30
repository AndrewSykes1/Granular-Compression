%Disable compression motor and close connection

writeline(s4,'MD'); %Motor disable
writeline(s4,'QT'); %End communication
fclose(s4);