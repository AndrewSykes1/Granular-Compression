directory_folder = 'C:\Users\Lab User\Desktop\ModernExperiments\';
info = string({dir(directory_folder).name});
x = str2double(extractAfter(info(startsWith(info, 'exp_')), 4));
target_folder = fullfile(directory_folder, sprintf('exp_%d', max(x)+1), '\');
mkdir(target_folder)
fprintf('Created directory exp_%d\n',max(x)+1)
