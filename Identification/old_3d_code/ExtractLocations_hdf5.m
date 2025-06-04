clc
clear all
close all
%Do a run
disp('*************************************');
disp('  Welcome to the particle extractor');
disp('*************************************');
disp(' ');

imagefolder= './staged_data/downscaling/downscaled_hdf5/';
savefolder = './processed_data';
mkdir(savefolder);

sigma0=1; %sharpness of gaussian spherical filter
AR_z=1; % aspect ratio z to x,y

start_image=1; %these are the images corresponding to each z slice in a single frame
end_image=359; % old: 823        last z slice (top)

x1=1; %these are limits of the region of interest
x2=511; % old: 1,1023

y1=1;  % old: 1,1223         %20;%!!both x2-x1+1 must be odd and same for y
y2=611;

c1=clock;

radius = 125; %measured avg radius of 50 particles

largeparts = zeros(1,4);

for i=202:202 % number of frames
    disp('====================');
    disp('MAIN LOOP');
    cml1=clock;
    disp(['Currently Extracting from Image i=' num2str(i) '.']);
    disp('Starting extraction of particles:'); 
    result = analyze_scan_orientations_hdf5_new_AP(imagefolder,i,start_image,end_image,x1,x2,y1,y2,radius,sigma0,AR_z);
    disp(['>>Found ' num2str(length(result)) ' particles.']);
    clear tempresultlarge
    tempresultlarge=[result i*ones(length(result),1)];
    largeparts=[largeparts; tempresultlarge];
    disp('Saving hdf5 files');
    save([savefolder 'scan' num2str(i,'%03.0f') '.mat'],'tempresultlarge');
    dlmwrite([savefolder 'scan' num2str(i,'%03.0f') '.txt'],tempresultlarge,'delimiter','\t');
    disp('>>Please don`t turn me off!');
    cml2=clock;
    disp(['>>Main loop cycle took ' num2str(etime(cml2,cml1)) ' seconds.']);
end %for i

largeparts(1,:)=[];
c2=clock;
save([savefolder 'Particle Locations and Orientations' '.mat'],'largeparts');
dlmwrite([savefolder 'Particle Locations and Orientations' '.txt'],largeparts,'delimiter','\t');
disp('=========================================');
disp(['Program has finished in: ' num2str(etime(c2,c1)) ' seconds.']);
largeparts=zeros(1,11);


[NNx NNy]=size(img);

uu=mk;
for n=-1:1
  for m=-1:1
    if(~(m==0 && n==0))  
      uu=(img>img(rem((1:NNx)+NNx+n-1,NNx)+1,rem((1:NNy)+NNy+m-1,NNy)+1)) & uu;
    end
  end
end

g1=find((img(:).*uu(:))>CutOff);
Npf=length(g1);
[spx spy]=ind2sub([NNx NNy],g1);
[junk iii]=sort(img(g1));
Xn=repmat(spx(iii)+i*spy(iii),1,Npf);
dd=abs(Xn.'-Xn);
iix=iii((sum(tril(dd<MinSep & dd~=0)))~=0);
g1=g1(setdiff(1:Npf,iix));
[junk iii]=sort(img(g1),'descend');
Npf=length(g1);
[spx spy]=ind2sub([NNx NNy],g1(iii));
