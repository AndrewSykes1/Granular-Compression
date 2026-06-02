function finishCompMove(mtr)

    % Wait until motor halts
    while true
        pause(0.05);

        try
            writeline(mtr, 'SC');  % Input Status
            response = char(readline(mtr));
            if str2num(response(6)) ~= 1
                break
            end
        catch
            continue
        end
    end
end