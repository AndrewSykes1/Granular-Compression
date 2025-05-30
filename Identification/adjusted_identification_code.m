% Load functions
addpath('./functions');

% Load and resize image
unadjusted_raw = imread('./staged_data/imageeee.bmp');  
raw = imresize(unadjusted_raw, 0.1);  % resized image for processing
raws = adapthisteq(raw);  % histogram equalization

% Get the dimensions of the original image (not the resized one)
[Nx, Ny, ~] = size(unadjusted_raw);  % Image size of original unadjusted image

hi = 250;  % hi and lo values come the image histogram
lo = 10;   % hi/lo=typical pixel value outside/inside
ri = (double(raws) - lo) / (hi - lo);  % normalized image

D = 20;          % Diameter
w = 1.3;         % Width
ss = 2 * fix(D / 2 + 4 * w / 2) - 1;  % size of ideal particle image
os = (ss - 1) / 2;  % (size-1)/2 of ideal particle image
[xx, yy] = ndgrid(-os:os, -os:os);  % ideal particle image grid
r = hypot(xx, yy);  % radial coordinate

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
padding = 50;  % Define padding size (adjust this as needed)
padded_img = zeros(Nx + 2 * padding, Ny + 2 * padding, 'like', unadjusted_raw);  % Create a padded image
padded_img(padding + 1:padding + Nx, padding + 1:padding + Ny, :) = unadjusted_raw;  % Place original image in the center

% Adjust the particle locations to account for the padding
px_padded = px + padding;  % Shift particle positions to the padded image
py_padded = py + padding;

% Create a figure to display the original image with overlaid predictions
h = figure(1);
imshow(output_img);  % Display the original image
hold on;
plot(py, px, 'w.', 'MarkerSize', 10);  % Overlay particle locations as white dots
hold off;

% Create a figure to display the chi-squared image with overlaid predictions
h = figure(2); 
set(h, 'Position', [100 100 600 600], 'Color', [1 1 1]);
simage([100*zerofill(ri, 2*os, 2*os) 100*zerofill(ri, 2*os, 2*os); 
        1./chiimg(ri, ipf(r, D, w)) 8*1./chiimg(ri, ipf(r, D, w))]); 
clim([0 100]);
hold on;
plot(py + 2*os + Ny, px, 'w.');  % Overlay particle locations on chi-squared image
hold off;
xlabel('Figure 3.');
