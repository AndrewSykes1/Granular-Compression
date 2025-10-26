function [outVol] = convolution3D_FFTdomain(inVol, inKer)
% convolution3D_FFTdomain - Fast 3D convolution via FFT
%
% size(outVol) = size(inVol) ('same' convolution)

    realInput = isreal(inVol) && isreal(inKer);
    indDb = isa(inVol, 'double');

    gpuVol = gpuArray(inVol);
    gpuInKer = gpuArray(inKer);

    gpuVolSize = size(gpuVol);
    gpuInKerSize = size(gpuInKer);

    fullSize = gpuVolSize + gpuInKerSize - 1;

    % Forward FFTs
    Fvol = fftn(gpuVol, fullSize);
    Fker = fftn(gpuInKer, fullSize);

    % Multiply in Fourier domain
    convFFT = Fvol .* Fker;

    % Inverse FFT
    convFull = ifftn(convFFT);

    % Extract "same" region
    extr = cell(1,3);
    for iDim = 1:3
        extr{iDim} = ceil((gpuInKerSize(iDim)-1)/2) + (1:gpuVolSize(iDim));
    end
    outVol = gather(convFull(extr{:}));

    % Force real if inputs were real
    if realInput
        outVol = real(outVol);
    end

    % Match precision
    if ~indDb
        outVol = single(outVol);
    end
end
