% Open serial port
port = 'COM5';
baudrate = 9600;

s = serial(port, 'BaudRate', baudrate, 'Terminator', 'LF');
fopen(s);

% Motor parameter function
function motorparam(mtr, rpm, acl, dcl, abrt)
    rpm_count = 8333 * rpm;
    acl_count = 5000 * acl;
    dcl_count = 5000 * dcl;
    abrt_count = 5000 * abrt;
    fprintf(mtr, 's r0xcb %d \n', rpm_count);
    fprintf(mtr, 's r0xcc %d \n', acl_count);
    fprintf(mtr, 's r0xcd %d \n', dcl_count);
    fprintf(mtr, 's r0xcf %d \n', abrt_count);
end

% Move to function
function moveto(mtr, usteps)
    fprintf(mtr, 's r0xca %d \n', usteps);
    fprintf(mtr, 't 1 \n');
end

% Set motor parameters
motorparam(s, 50, 10, 10, 50);

% Move forward 1000 microsteps
moveto(s, 1000);
pause(5); % wait for motor to move

% Move back to zero
moveto(s, 0);
pause(5);

% Close serial port
fclose(s);
delete(s);
clear s;
