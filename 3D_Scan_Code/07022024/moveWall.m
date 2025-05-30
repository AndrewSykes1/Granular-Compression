function moveWall(steps,driver)

%Make data to send
Command=strcat('FL',num2str(steps));

%Move wall
writeline(driver,Command);

end