% JCORR3D.M
% This function performs a correlation on a 3D volume with a 3D kernel. It
% is faster than MATLAB's convn or imfilter, and produces the same result 
% (Relative Error is of order 1E-12).
% The drawback is that for large correlations out-of-memory errors might occur,
% this is solved by splitting the volume which is convoluted.
%
% Written and (c) by:   Joost Weijs, University of Twente, The Netherlands
%
%    USAGE:
%
%       out = jconv3d ( dataset , kernel , split )
%
%    INPUTS:
%       dataset: A 3-dimensional dataset to be convoluted with the mirrored kernel.
%       Type can be single or double.
%
%       kernel: A 3-dimensional kernel with which the dataset is
%       convoluted. Can also be single or double precision. The kernel is
%       mirrored to perform the correlation.
%
%       split: An integer value. The dataset volume is splitted in split
%       (more or less) equal parts in the z-direction. Using the
%       overlap-add method the convolution of the complete dataset will be
%       calculated. If you encounter OUT OF MEMORY errors while running
%       this function, you might want to increase this value. The cost of
%       higher values are slightly increased computation times.
%
%     OUTPUT:
%       out: The result of the correlation
%
%       (c) 2008 Joost Weijs, University of Twente, The Netherlands


function out=jcorr3d(dataset,kernel,split)

    sizedataset=size(dataset);
    sizekernel=size(kernel);

    %invert kernel
    kernel=kernel(sizekernel(1):-1:1,sizekernel(2):-1:1,sizekernel(3):-1:1);
    C=zeros(sizedataset+sizekernel-[1,1,1]);
    z_start=1;
    i=0;
    while z_start<sizedataset(3)
        i=i+1;
        z_end=min([ceil(i*sizedataset(3)/split),sizedataset(3)]);
        A=zeros(sizedataset(1)+sizekernel(1)-1,sizedataset(2)+sizekernel(2)-1,z_end-z_start+sizekernel(3));
        B=A;
        A(1:sizedataset(1),1:sizedataset(2),1:z_end-z_start+1)   = dataset(:,:,z_start:z_end);    
        B(1:sizekernel(1) ,1:sizekernel(2) ,1:sizekernel(3))     = kernel;
        fftA = fftn(A);
        fftB = fftn(B);
        fftC = fftA.*fftB;
        Ct   = ifftn(fftC);
        C(:,:,z_start:z_end+sizekernel(3)-1)   = C(:,:,z_start:z_end+sizekernel(3)-1) + Ct;
        z_start=z_end+1;
        
    end

    %Bring back to the original data size by cutting the zero correlated
    %borders
    sC=size(C);
    out=C( round(sizekernel(1)/2) : round(sC(1) - sizekernel(1)/2) ...
            ,  round(sizekernel(2)/2) : round(sC(2) - sizekernel(2)/2) ...
            ,  round(sizekernel(3)/2) : round(sC(3) - sizekernel(3)/2)  );

end