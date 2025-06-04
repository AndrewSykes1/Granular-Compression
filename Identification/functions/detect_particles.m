function positions = detect_particles(image)
    % Convert to double and enhance contrast
    img = im2double(image);
    enhanced_img = adapthisteq(img);

    % Parameters for radius search
    max_radius = 30;   % max radius to check
    step_radius = 1;   % radius step size
    threshold_drop = 0.3; % intensity drop threshold to define edge

    % Find approximate centers using imregionalmax on blurred image
    bw = imregionalmax(imgaussfilt(enhanced_img,2));
    [py, px] = find(bw);

    num_centers = length(px);
    radii = zeros(num_centers,1);

    % For each center, estimate radius by checking radial intensity drop
    for k = 1:num_centers
        x = px(k);
        y = py(k);

        max_r = 0;
        center_val = enhanced_img(y,x);

        for r = step_radius:step_radius:max_radius
            % Sample points on circle perimeter
            theta = linspace(0, 2*pi, 36);
            xs = round(x + r*cos(theta));
            ys = round(y + r*sin(theta));

            % Keep points inside image
            valid = xs > 0 & xs <= size(enhanced_img,2) & ys > 0 & ys <= size(enhanced_img,1);
            xs = xs(valid);
            ys = ys(valid);

            % Get intensity values on perimeter
            vals = arrayfun(@(a,b) enhanced_img(b,a), xs, ys);

            % Check if average intensity dropped below threshold relative to center
            if mean(vals) < center_val - threshold_drop
                max_r = r;
                break;
            end
        end

        if max_r == 0
            max_r = max_radius; % max if no drop found
        end

        radii(k) = max_r;
    end

    % Return struct with x,y,r
    positions.x = double(px);
    positions.y = double(py);
    positions.r = radii;
end
