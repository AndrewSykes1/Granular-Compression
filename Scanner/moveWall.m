% Send move command
Command=strcat('FL',num2str(compStep));
writeline(s4,Command);

% Show info
disp(['Wall Counter: ', num2str(scanNumber)]);
disp(['Moving wall: ' , num2str(compStep)]);
compStep = -1*compStep; % Flip for next command