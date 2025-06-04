image_path = './staged_data/imageeee.bmp';

% Get particle positions from your function
positions = detect_particles(image_path);
px = positions.x;
py = positions.y;

% Display original image and plot points
figure(1);
imshow(original_img);
hold on;
plot(py, px, 'w.', 'MarkerSize', 10);
hold off;



