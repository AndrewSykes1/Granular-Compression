function [chi3D, Wip2] = chiimg3D_FFT(img, ip, W, Wip2)
% chiimg3D_FFT  Calculate 3D chi-squared image using FFT convolution
%
% chi3D : 3D chi-squared image (minima = best match)
% img   : 3D image
% ip    : 3D particle template
% W     : weight array (optional, default = ip)
% Wip2  : precomputed weighting factor (optional)

    if nargin < 3 || isempty(W)
        W = ip;
    end

    % Precompute denominator if not passed in
    if nargin < 4 || isempty(Wip2)
        blk = ones(size(img));
        Wip2 = convolution3D_FFTdomain(blk, ip.^2 .* W);
    end

    % Flip template and weight for convolution (for true correlation)
    ip = ip(end:-1:1, end:-1:1, end:-1:1);
    W  = W(end:-1:1, end:-1:1, end:-1:1);

    % FFT-based convolutions
    num1 = convolution3D_FFTdomain(img, ip .* W);   % cross term
    num2 = convolution3D_FFTdomain(img.^2, W);      % squared term

    % Chi-squared image
    chi3D = 1 + (-2 * num1 + num2) ./ Wip2;
end
