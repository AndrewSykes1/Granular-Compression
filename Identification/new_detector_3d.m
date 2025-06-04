C_farness = 15; % distance threshold
layer_range = 3; % how many layers to check up/down
real_dict = containers.Map('KeyType', 'double', 'ValueType', 'any');
center_dict = containers.Map('KeyType', 'double', 'ValueType', 'any');

% First, detect particles in each layer
for z = 1:layer_count
    img = get_image_for_layer(z); % your function to get image z
    centers = detect_particles(img); % returns struct with x, y, radius
    center_dict(z) = centers;
    real_dict(z) = []; % initialize
end

% Now, check for local radius maxima
for z = 1:layer_count
    current = center_dict(z);
    real_particles = [];

    for i = 1:length(current.x)
        cx = current.x(i);
        cy = current.y(i);
        cr = current.r(i);
        is_largest = true;

        for dz = -layer_range:layer_range
            if dz == 0 || ~isKey(center_dict, z + dz)
                continue;
            end
            neighbor = center_dict(z + dz);
            for j = 1:length(neighbor.x)
                nx = neighbor.x(j);
                ny = neighbor.y(j);
                nr = neighbor.r(j);
                if norm([cx, cy] - [nx, ny]) < C_farness && nr > cr
                    is_largest = false;
                    break;
                end
            end
            if ~is_largest
                break;
            end
        end

        if is_largest
            real_particles = [real_particles; [cx, cy, cr]];
        end
    end

    real_dict(z) = real_particles; % store retained centers
end
