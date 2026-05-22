function finishMove(mtr)
    while(true)
        
        % Flush outputs
        pause(0.1); 
        flushinput(mtr);
    
        % Access movement status
        cmd = sprintf('g r0xa0 \r');
        fprintf(mtr,cmd);

        % Parse for status
        retInfo = strsplit(fscanf(mtr));
        status = str2double(retInfo{2});

        % Return status
        if bitand(status,134217728) == 0
            break;
        end

    end
end