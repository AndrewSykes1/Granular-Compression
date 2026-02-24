function motorparam(mtr,rpm,acl,dcl,abrt)

% Parameters
rpm_count=8333*rpm;
acl_count=5000*acl;
dcl_count=5000*dcl;
abrt_count=5000*abrt;

cb=sprintf('s r0xcb %d \n', rpm_count);  % Max velocity
cc=sprintf('s r0xcc %d \n', acl_count);  % Max acceleration rate
cd=sprintf('s r0xcd %d \n' , dcl_count); % Max deceleration rate
cf=sprintf('s r0xcf %d \n', abrt_count); % Abort deceleration rate

fprintf(mtr, cb);
fprintf(mtr, cc);
fprintf(mtr, cd);
fprintf(mtr, cf);
end