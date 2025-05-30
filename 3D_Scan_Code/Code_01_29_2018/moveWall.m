function moveWall(steps,driver)

%Make data to send
Command=strcat('FL',num2str(steps));

%Move wall
SendCompCommand(driver,Command);

end