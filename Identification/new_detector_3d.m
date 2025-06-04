C_farness = 15;      % distance threshold
layer_range = 3;     % how many layers up/down to check
real_dict = containers.Map('KeyType', 'double', 'ValueType', 'any');
center_dict = containers.Map('KeyType', 'double', 'ValueType', 'any');

% Assume layer_count and filename/dataset defined earlier

for z = 1:layer_count
    img = h5read(filename, dataset, [1 1 z], [info.Dataspace.Size(1), info.Dataspace.Size(2), 1]);
    if size(img,3) > 1
        img = rgb2gray(img);
    end
    centers = detect_particles(img); % returns struct with x,y,r fields
    center_dict(z) = centers;
    real_dict(z) = [];
end

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
                if norm([cx - nx, cy - ny]) < C_farness && nr > cr
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

    real_dict(z) = real_particles;
end
