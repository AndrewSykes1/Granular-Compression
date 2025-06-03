function out_as=analyze_scan_orientations_hdf5_new_AP(imagefolder,scan_number,start_image,end_image,x1,x2,y1,y2,radius,sigma0,AR_z)
%A new version of location extraction using modern Matlab functions
tic
splits = 1; %Splits the volume into separate parts to prevent out of memory issues, not rellevant to us
%KERNEL Radius is larger than physical radius
kx=round(2.5*radius);%these are the matrix dimesions of the box that contains the kernel
ky=round(2.5*radius);
kz=round(2.5*radius/AR_z);%AR_z=1 currently
no_images=end_image-start_image+1;

disp('***********************************************');
disp('This is the analyze_scan function');
%%
%First create the Gauss_sphere
disp('a_s: Creating (non z-deformed(!)) Gaussian sphere');
Gauss_sph=single(Gauss_sphere(radius,sigma0,kx,ky,kz,AR_z));
%%
%Load all images%creates 3d image array and makes a cropped version to
%line up with final moments
disp('a_s: Loading and pre-processing images');
IMS=load_images_hdf5(start_image,end_image,x1,x2,y1,y2,imagefolder,scan_number);

%Adjust level removing upper and lower parts containing no information
IMS=IMS/4096;
max_level=0.85;
min_level=0.15;
max_index=IMS>max_level;
IMS(max_index)=max_level;
min_index=IMS<min_level;
IMS(min_index)=min_level;
IMS=(IMS-min_level)/(max_level-min_level);

%Adjust brightness of the image to a mean level
tsg=adaptthresh(IMS,0.5,'NeighborhoodSize',4*floor(radius/2)+1,'Statistic','gauss'); %Using smooth gauss filter of the diameter of the particle
IMS=rescale(IMS./tsg);


%Convolve
disp('a_s: Convolving... This may take a while');
Convol=jcorr3d(IMS,Gauss_sph,splits);
Convol=rescale(Convol);

%Find maximums
disp('a_s: Searching for maximums');
maxlocations=imregionalmax(Convol);
pindex=find(maxlocations);
[x,y,z]=ind2sub(size(Convol),pindex);

%Clean impossible particles located too close to one another, keep the one
%with bigger area
disp('a_s: Cleaning found particles list');
numparticles=length(pindex);


% Output results
Result=zeros(numparticles,3);
Result(:,1)=x;
Result(:,2)=y;
Result(:,3)=z;

out_as=Result;