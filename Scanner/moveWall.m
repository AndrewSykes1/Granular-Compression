
% Send move command
cmd = strcat('FL',num2str(compStep));
writeline(s4,cmd);

% Show info
disp(['Wall Counter: ', num2str(scanNumber)]);
disp(['Moving wall: ' , num2str(compStep)]);

% Flip for next move
compStep = -1*compStep; 

% Clear buffer
pause(.01); flush(s4);


% Wait until motor halts
while true
    try
        writeline(s4, 'SC');  % Input Status
        response = char(readline(s4));

        if str2num(response(6)) ~= 1
            break
        end
    catch
        continue
    end
end


