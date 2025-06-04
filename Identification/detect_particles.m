function positions = detect_particles(image_path)
    addpath('./functions');

    % Load and preprocess image
    original_img = imread(image_path);
    resized_img = imresize(original_img, 0.1);
    enhanced_img = adapthisteq(resized_img);

    % Image size info
    [Nx, Ny, ~] = size(original_img);

    % Intensity normalization thresholds
    lo = 10;
    hi = 250;
    norm_img = (double(enhanced_img) - lo) / (hi - lo);

    % Ideal particle specs and grid setup
    D = 20;       
    w = 1.3;      
    ss = 2 * fix(D / 2 + 4 * w / 2) - 1;
    os = (ss - 1) / 2;
    [xx, yy] = ndgrid(-os:os, -os:os);
    r = hypot(xx, yy);

    % Find particle centers (peaks)
    Cutoff = 5;
    MinSep = 5;
    [~, px, py] = findpeaks(1 ./ chiimg(norm_img, ipf(r, D, w)), 1, Cutoff, MinSep);

    % Scale coordinates to original image size
    scale_factor = Nx / size(resized_img, 1);
    px = px * scale_factor;
    py = py * scale_factor;

    % Adjust coordinates to correct fitting
    adjustment_factor = -100;
    px = px + adjustment_factor;
    py = py + adjustment_factor;

    % Remove out-of-bounds (no padding needed here since returning positions)
    valid_mask = (px > 0) & (px <= Nx) & (py > 0) & (py <= Ny);
    px = px(valid_mask);
    py = py(valid_mask);

    % Return positions as struct with arrays
    positions.x = px;
    positions.y = py;
end
