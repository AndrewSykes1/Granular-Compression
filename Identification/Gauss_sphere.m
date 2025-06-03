%Create an array (3D) with a Gaussian sphere
%Use at you own risk
%Joost Weijs, 2008

function out = Gauss_sphere(a0,sigma0,ni,nj,nk,AR_z);

Gauss_sph=zeros(ni,nj,nk);

for i=1:ni
    for j=1:nj
        for k=1:nk

            r = sqrt( (ni/2 - i)^2 + (nj/2 - j)^2 + (AR_z*(nk/2 - k))^2 );
            %Gauss_sph(i,j,k)= -2*(r-a0)/(2*sigma0^2) * exp(-(r-a0)^2/(2*sigma0^2));
            Gauss_sph(i,j,k)= (1.0-tanh((r-a0)/sigma0))/2.0;

        
        end %for k
    end %for j
end %for i

%Gauss_sph=Gauss_sph-min(min(min(Gauss_sph)));
%Gauss_sph=Gauss_sph*255/max(max(max(Gauss_sph)));
%Gauss_sph=uint8(round(Gauss_sph));

%exp(f(r))
%f(r)=-(r-a0)^2/(2*sigma0^2)

%d/dr exp(f(r)) = d/df exp(f(r)) * df/dr

%= exp(f(r)) * -2(r-a0)/(2*sigma0^2)

out=Gauss_sph;