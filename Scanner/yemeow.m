%%% MOTOR TEST SCRIPT %%%
clear all;
close all;
clc;
serialportlist("available")

disp('=== MOTOR TEST SCRIPT ===');
disp('Testing each motor individually...');
disp(' ');

%%% Setup Motors %%%
disp('Opening serial connections...');

% Near Laser
s1=serial('COM5');
fopen(s1);
fprintf(s1,'s r0x24 31 \n;');
pause(0.1);
fprintf(s1,'s r0xc8 0 \n;');
pause(0.1);
disp('✓ s1 (Near Laser - COM5) opened');

% Camera
s2=serial('COM2');
fopen(s2);
fprintf(s2,'s r0x24 31 \n;');
pause(0.1);
fprintf(s2,'s r0xc8 0 \n;');
pause(0.1);
disp('✓ s2 (Camera - COM2) opened');

% Far Laser
s3=serial('COM1');
fopen(s3);
fprintf(s3,'s r0x24 31 \n;');
pause(0.1);
fprintf(s3,'s r0xc8 0 \n;');
pause(0.1);
disp('✓ s3 (Far Laser - COM1) opened');

disp(' ');
disp('All motors initialized. Starting movement tests...');
disp(' ');

%%% Define helper functions %%%
function motorparam_test(mtr, name, rpm, acl, dcl, abrt)
    fprintf('Setting parameters for %s...\n', name);
    rpm_count = 8333*rpm;
    acl_count = 5000*acl;
    dcl_count = 5000*dcl;
    abrt_count = 5000*abrt;
    
    fprintf(mtr, sprintf('s r0xcb %d \n', rpm_count));
    pause(0.05);
    fprintf(mtr, sprintf('s r0xcc %d \n', acl_count));
    pause(0.05);
    fprintf(mtr, sprintf('s r0xcd %d \n', dcl_count));
    pause(0.05);
    fprintf(mtr, sprintf('s r0xcf %d \n', abrt_count));
    pause(0.05);
end

function moveto_test(mtr, name, usteps)
    fprintf('Moving %s to position %d...\n', name, usteps);
    movstr = sprintf('s r0xca %d \n', usteps);
    fprintf(mtr, movstr);
    pause(0.05);
    fprintf(mtr, 't 1 \n');
    pause(0.1);
end

%%% TEST 1: Move s1 (Near Laser) %%%
disp('--- TEST 1: Near Laser (s1 - COM5) ---');
motorparam_test(s1, 's1', 40, 20, 20, 50);
moveto_test(s1, 's1', 50000);  % Increased distance
disp('Motor should be moving now... waiting for completion');
pause(15);  % Wait longer for movement to complete
disp(' ');

%%% TEST 2: Move s2 (Camera) %%%
disp('--- TEST 2: Camera (s2 - COM2) ---');
motorparam_test(s2, 's2', 40, 20, 20, 50);
moveto_test(s2, 's2', 50000);  % Increased distance
disp('Motor should be moving now... waiting for completion');
pause(15);  % Wait longer for movement to complete
disp(' ');

%%% TEST 3: Move s3 (Far Laser) %%%
disp('--- TEST 3: Far Laser (s3 - COM1) ---');
motorparam_test(s3, 's3', 40, 20, 20, 50);
moveto_test(s3, 's3', 50000);  % Increased distance
disp('Motor should be moving now... waiting for completion');
pause(15);  % Wait longer for movement to complete
disp(' ');

%%% Return all motors to home %%%
disp('--- RETURNING ALL MOTORS TO HOME (position 0) ---');

disp('Homing s1...');
motorparam_test(s1, 's1', 40, 20, 20, 50);
moveto_test(s1, 's1', 0);
pause(15);  % Wait for return

disp('Homing s2...');
motorparam_test(s2, 's2', 40, 20, 20, 50);
moveto_test(s2, 's2', 0);
pause(15);  % Wait for return

disp('Homing s3...');
motorparam_test(s3, 's3', 40, 20, 20, 50);
moveto_test(s3, 's3', 0);
pause(15);  % Wait for return

disp(' ');
disp('Test complete! All motors should be back at home position.');

%%% Cleanup %%%
fclose(s1);
delete(s1);
fclose(s2);
delete(s2);
fclose(s3);
delete(s3);
clear s1 s2 s3;

disp('Motors closed. Test finished.');