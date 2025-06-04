addpath('./functions');

% Load and resize image
unadjusted_raw = imread('./staged_data/imageeee.bmp');  
raw = imresize(unadjusted_raw, 0.1);  % resized image for processing
raws = adapthisteq(raw);  % histogram equalization | (increasing contrast)

% Get the dimensions of the original image (not the resized one)
[Nx, Ny, ~] = size(unadjusted_raw);  % Image size of original unadjusted image

% define intensity thresholds and normalize with them
hi = 250;  % hi and lo values come the image histogram
lo = 10;   % hi/lo=typical pixel value outside/inside
ri = (double(raws) - lo) / (hi - lo);  % normalized image

% Ideal partical specifications, and create a grid for imaginary ones
D = 20;          % Diameter
w = 1.3;         % Width
ss = 2 * fix(D / 2 + 4 * w / 2) - 1;  % size of ideal particle image
os = (ss - 1) / 2;  % (size-1)/2 of ideal particle image
[xx, yy] = ndgrid(-os:os, -os:os);  % ideal particle image grid
r = hypot(xx, yy);  % radial coordinate

% Find intensity peaks in chiimg (ie find center of particals)
Cutoff = 5;      % minimum peak intensity
MinSep = 5;      % minimum separation between peaks
[Np, px, py] = findpeaks(1 ./ chiimg(ri, ipf(r, D, w)), 1, Cutoff, MinSep);  % find maxima

% Scale coordinates back to original size
scale_factor = size(unadjusted_raw, 1) / size(raw, 1);
px = px * scale_factor;
py = py * scale_factor;

% Display prediction over original data
output_img = unadjusted_raw;

% Padding the original image
padding = 105;  % Define padding size (adjust this as needed)
padded_img = zeros(Nx + 2 * padding, Ny + 2 * padding, 'like', unadjusted_raw);  % Create a padded image
padded_img(padding + 1:padding + Nx, padding + 1:padding + Ny, :) = unadjusted_raw;  % Place original image in the center

% Remove out of bounds predictions
mask = (px >= padding) & (px <= Nx + padding) & (py >= padding) & (py <= Ny + padding);

% Create a figure to display the original image with overlaid predictions
h = figure(1);
imshow(padded_img);
hold on;
plot(py(mask), px(mask), 'w.', 'MarkerSize', 10);  % Overlay particle locations as white dots
hold off;
