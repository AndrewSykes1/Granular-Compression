function motorparam(mtr,rpm,acl,dcl,abrt)

% Parameters
velCount  = 8333*rpm;
accCount  = 5000*acl;
dccCount  = 5000*dcl;
abrtCount = 5000*abrt;

% Create motor limit commands
cb=sprintf('s r0xcb %d \n', velCount);  % Max velocity
cc=sprintf('s r0xcc %d \n', accCount);  % Max acceleration rate
cd=sprintf('s r0xcd %d \n' , dccCount); % Max deceleration rate
cf=sprintf('s r0xcf %d \n', abrtCount); % Abort deceleration rate

% Execute limit commands
fprintf(mtr, cb);
fprintf(mtr, cc);
fprintf(mtr, cd);
fprintf(mtr, cf);
end