fprintf(s1,'s r0x24 31 \n;');
fprintf(s1,'s r0xc8 256 \n;');
fprintf(s1,'s r0xca 50000 \n;');
fprintf(s1,'s r0xcb 83333 \n;');
fprintf(s1,'s r0xcc 50000 \n;');
fprintf(s1,'s r0xcd 50000 \n;');
fprintf(s1,'s r0xcf 50000 \n;');
fprintf(s1,'t 1');


% compressed in one line:
% fprintf(s1,'s r0x24 31 \n; s r0xca 50000 \n; s r0xcb 83333 \n; s r0xcc 50000 \n; s r0xcd 50000 \n; s r0xcf 50000 \n; t 1')