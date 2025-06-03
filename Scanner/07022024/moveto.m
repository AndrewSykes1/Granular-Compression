function moveto(mtr, usteps)
    movstr=sprintf('s r0xca %d \n', usteps);
    writeline(mtr, movstr);
    writeline(mtr, 't 1 \n');
end