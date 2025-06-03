function motorparam(mtr,rpm,acl,dcl,abrt)
rpm_count=8333*rpm;
acl_count=5000*acl;
dcl_count=5000*dcl;
abrt_count=5000*abrt;
cb=sprintf('s r0xcb %d \n', rpm_count);
cc=sprintf('s r0xcc %d \n', acl_count);
cd=sprintf('s r0xcd %d \n' , dcl_count);
cf=sprintf('s r0xcf %d \n', abrt_count);
writeline(mtr, cb);
writeline(mtr, cc);
writeline(mtr, cd);
writeline(mtr, cf);
end