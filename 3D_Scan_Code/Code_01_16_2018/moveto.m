function moveto(mtr, usteps)
    movstr=sprintf('s r0xca %d \n', usteps);
    fprintf(mtr, movstr);
    fprintf(mtr, 't 1 \n');
end