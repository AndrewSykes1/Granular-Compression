function moveWall(mtr,instr)

    % Write move command
    cmd = strcat('FL',num2str(instr));
    writeline(mtr,cmd);

    % Clear buffer
    pause(.01); flush(mtr);

    % Wait until motor halts
    finishCompMove(mtr);
    
end




