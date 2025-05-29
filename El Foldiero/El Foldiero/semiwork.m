% Load and resize image
raww = imread('imageeee.bmp');  
raw = imresize(raww, 0.1);

raws = adapthisteq(raw);

[Nx Ny]=size(raw);       % image size
hi=250;  % hi and lo values come the image histogram
lo=10;   % hi/lo=typical pixel value outside/inside
ri = (double(raws)-lo)/(hi-lo);  % normalized image

D=20;          % Diameter
w=1.3;         % Width
ss=2*fix(D/2+4*w/2)-1;          % size of ideal particle image
os=(ss-1)/2;                    % (size-1)/2 of ideal particle image
[xx, yy]=ndgrid(-os:os,-os:os);  % ideal particle image grid
r=hypot(xx,yy);                 % radial coordinate

Cutoff=5;      % minimum peak intensity
MinSep=5;      % minimum separation between peaks
[Np, px, py]=findpeaks(1./chiimg(ri,ipf(r,D,w)),1,Cutoff,MinSep);  % find maxima

h=figure(2); set(h,'Position',[100 100 600 600],'Color',[1 1 1]);
simage([100*zerofill(ri,2*os,2*os) 100*zerofill(ri,2*os,2*os); 1./chiimg(ri,ipf(r,D,w)) 8*1./chiimg(ri,ipf(r,D,w))]); clim([0 100])
hold on;
plot(py+2*os+Ny,px,'w.');
hold off;
xlabel('Figure 3.');

