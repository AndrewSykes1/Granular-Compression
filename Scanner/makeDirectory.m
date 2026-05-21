% Global experiment directory
saveDirectory = 'C:\Users\Lab User\Desktop\ModernExperiments\';

% Make folder name 
info = string({dir(saveDirectory).name}); % List of exp folders
x = str2double(extractAfter(info(startsWith(info, 'exp_')), 4)); % Recentest number
experimentFolder = fullfile(saveDirectory, sprintf('exp_%d', max(x)+1), '\');

% Create folder
mkdir(experimentFolder);
fprintf('Created directory exp_%d\n',max(x)+1);
