filename = '.\staged_data\downscaling\downscaled_hdf5\DownScan_202.hdf5';
dataset = '/RawData/Scan_202'; % check your HDF5 structure

info = h5info(filename, dataset);
num_layers = info.Dataspace.Size(end);

fprintf('%d\n', num_layers)

threshold = 10; % max linking distance
max_len = 50;    % max layers per particle
particles = {}; % cell array of particles
layer_centers = containers.Map('KeyType','double','ValueType','any');

num_layers = length(images); % your image stack

for z = 1:num_layers
    centers = detect_centers(images{z}); % your 2D detection, returns Nx2 [x,y]
    layer_centers(z) = [centers];
    
    if z <= 2

    for i = 1:size(centers,1) % i=partical index
        cx = centers(i,1);
        cy = centers(i,2);
        matched = false;

        for p = 1:length(particles)
            last_point = particles{p}(end,:);
            dist = norm([cx, cy, z] - last_point);
            if dist < threshold && size(particles{p},1) < max_len
                particles{p}(end+1,:) = [cx, cy, z];
                matched = true;
                break;
            end
        end
        if ~matched
            particles{end+1} = [cx, cy, z];
        end
    end
end

% Compute average centers
centers_3d = zeros(length(particles),3);
for p = 1:length(particles)
    centers_3d(p,:) = mean(particles{p},1);
end
