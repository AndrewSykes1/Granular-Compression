
% establish stepper mode
fprintf(s1,'s r0x24 31 \n;');

% set movement mode
fprintf(s1,'s r0xc8 0 \n;');

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

% wait until done
pause(1)

s1.Terminator='CR';
st='junk';
while ~strcmp('v 0',st)
    clear st
    st='junk';

    fprintf(s1,'\n;');
    fprintf(s1,'g r0xa0 \n;');
    st=fgetl(s1);
    %mvar=sscanf(st, 'v %d');
end
fprintf(s1,'s r0xc8 0 \n;');
% return to start
fprintf(s1,'s r0xca 0 \n;');

% execute return
fprintf(s1,'t 1');