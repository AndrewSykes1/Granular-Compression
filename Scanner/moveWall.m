function moveWall(steps,driver)

%Make data to send
Command=strcat('FL',num2str(steps));

%Move wall
writeline(driver,Command);

disp(['Wall Counter: ', num2str(scanNumber)]);
disp(['Moving wall: ' , num2str(motionSeries(scanNumber))]);

end