saveDirectory = 'C:\Users\Lab User\Desktop\ModernExperiments\';
info = string({dir(saveDirectory).name});
x = str2double(extractAfter(info(startsWith(info, 'exp_')), 4));
experimentFolder = fullfile(saveDirectory, sprintf('exp_%d', max(x)+1), '\');
mkdir(experimentFolder)
fprintf('Created directory exp_%d\n',max(x)+1)
