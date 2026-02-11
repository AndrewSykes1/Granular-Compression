target_folder = 'C:\Users\Lab User\Desktop\ModernExperiments';

info = string({dir('C:\Users\Lab User\Desktop\ModernExperiments').name});
x = str2double(extractAfter(info(startsWith(info, 'exp_')), 4));
mkdir(fullfile(target_folder, sprintf('exp_%d', max(x)+1)))


