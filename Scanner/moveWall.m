%Compression Motor
driver = s4;

compStep = -1*compStep;

%Make data to send
Command=strcat('FL',num2str(compStep));

%Move wall
writeline(driver,Command);

disp(['Wall Counter: ', num2str(scanNumber)]);
disp(['Moving wall: ' , num2str(compStep)]);