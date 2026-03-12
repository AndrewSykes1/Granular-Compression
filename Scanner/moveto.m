function moveto(mtr, usteps)
    
    % Move to position (usteps)
    movstr=sprintf('s r0xca %d \n', usteps); 
    fprintf(mtr, movstr);

    % Activate movement
    fprintf(mtr, 't 1 \n');
end