I = imread('./staged_data/imageeee.bmp');       
I = imresize(I,0.1);

[Nx Ny]=size(I);      
hi=250;  
lo=10;   
ra=(double(I)-lo)/(hi-lo);  

D=20;          
w=1.3;         
ss=2*fix(D/2+4*w/2)-1;          
os=(ss-1)/2;                    
[xx, yy]=ndgrid(-os:os,-os:os);  
r=hypot(xx,yy);                

tsg=adaptthresh(ra, 0.4,'NeighborhoodSize',4*floor(D/2)+1,'Statistic','gauss', 'ForegroundPolarity', 'bright'); 
ri = rescale(double(ra)./tsg);

Cutoff=5;      
MinSep=5;      
[Np, px, py]=findpeaks(1./chiimg(ri,ipf(r,D,w)),1,Cutoff,MinSep); 

h=figure(2); set(h,'Position',[100 100 600 600],'Color',[1 1 1]);
simage([100*zerofill(ri,2*os,2*os) 100*zerofill(ri,2*os,2*os); 1./chiimg(ri,ipf(r,D,w)) 8*1./chiimg(ri,ipf(r,D,w))]); clim([0 100])
hold on;
plot(py+2*os+Ny,px,'w.');
hold off;
xlabel('Figure 3.');

