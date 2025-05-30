% establish stepper mode
fprintf(s1,'s r0x24 31 \n;');
fprintf(s2,'s r0x24 31 \n;');
fprintf(s3,'s r0x24 31 \n;');

% set movement mode
fprintf(s1,'s r0xc8 0 \n;');
fprintf(s2,'s r0xc8 0 \n;');
fprintf(s3,'s r0xc8 0 \n;');

% set distance
fprintf(s1,'s r0xca 100000 \n;');
fprintf(s2,'s r0xca 100000 \n;');
fprintf(s3,'s r0xca 100000 \n;');

% set velocity
fprintf(s1,'s r0xcb 166666 \n;');
fprintf(s2,'s r0xcb 166666 \n;');
fprintf(s3,'s r0xcb 166666 \n;');

% set acceleration
fprintf(s1,'s r0xcc 50000 \n;');
fprintf(s2,'s r0xcc 50000 \n;');
fprintf(s3,'s r0xcc 50000 \n;');

% set deceleration
fprintf(s1,'s r0xcd 50000 \n;');
fprintf(s2,'s r0xcd 50000 \n;');
fprintf(s3,'s r0xcd 50000 \n;');

% set abort deceleration
fprintf(s1,'s r0xcf 50000 \n;');
fprintf(s2,'s r0xcf 50000 \n;');
fprintf(s3,'s r0xcf 50000 \n;');

% execute movement
fprintf(s1,'t 1');
fprintf(s2,'t 1');
fprintf(s3,'t 1');

% wait until done
pause(6)

% set backwards distance
fprintf(s1,'s r0xca 0 \n;');
fprintf(s2,'s r0xca 0 \n;');
fprintf(s3,'s r0xca 0 \n;');

% execute return
fprintf(s1,'t 1');
fprintf(s2,'t 1');
fprintf(s3,'t 1');