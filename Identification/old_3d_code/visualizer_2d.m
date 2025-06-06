addpath('C:\Users\Lab User\Granular-Compression\Identificatio\functions');

% Load and preprocess image
original_img = imread('C:\Users\Lab User\Granular-Compression\Identification\staged_data\imageeee.bmp');
resized_img = imresize(original_img, 0.1);
enhanced_img = adapthisteq(resized_img);

% Image size info
[Nx, Ny, ~] = size(original_img);

% Intensity normalization thresholds
lo = 10;
hi = 250;
norm_img = (double(enhanced_img) - lo) / (hi - lo);

% Ideal particle specs and grid setup
D = 20;       % Diameter
w = 1.3;      % Width
ss = 2 * fix(D / 2 + 4 * w / 2) - 1;
os = (ss - 1) / 2;
[xx, yy] = ndgrid(-os:os, -os:os);
r = hypot(xx, yy);

% Find particle centers (peaks) in processed image
Cutoff = 5;
MinSep = 5;
[Np, px, py] = findpeaks(1 ./ chiimg(norm_img, ipf(r, D, w)), 1, Cutoff, MinSep);

% Scale coordinates to original image size
scale_factor = Nx / size(resized_img, 1);
px = px * scale_factor;
py = py * scale_factor;

valid_pos = (px >= 0) & (px <= Nx) & (py >= 0) & (py <= Ny);



% Pad original image for visualization
padding = 105;
padded_img = zeros(Nx + 2 * padding, Ny + 2 * padding, 'like', original_img);
padded_img(padding + 1:padding + Nx, padding + 1:padding + Ny, :) = original_img;

% Filter out-of-bounds detections
valid_mask = (px >= padding) & (px <= Nx + padding) & (py >= padding) & (py <= Ny + padding);

% Display results
figure(1);
imshow(padded_img);
hold on;
plot(py(valid_mask), px(valid_mask), 'w.', 'MarkerSize', 10);
hold off;
