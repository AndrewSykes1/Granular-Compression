% establish stepper mode
fprintf(s1,'s r0x24 31 \n;');

% set movement mode
fprintf(s1,'s r0xc8 256 \n;');

% set distance
fprintf(s1,'s r0xca 100000 \n;');

% set velocity
fprintf(s1,'s r0xcb 166666 \n;');

% set acceleration
fprintf(s1,'s r0xcc 50000 \n;');

% set deceleration
fprintf(s1,'s r0xcd 50000 \n;');

% set abort deceleration
fprintf(s1,'s r0xcf 50000 \n;');

% execute movement
fprintf(s1,'t 1');
