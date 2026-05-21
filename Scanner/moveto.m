function moveto(mtr, usteps)
    
    % Move to position (usteps)
    moveCommand = sprintf('s r0xca %d \n', usteps); 
    fprintf(mtr, moveCommand);
    fprintf(mtr, 't 1 \n');
end