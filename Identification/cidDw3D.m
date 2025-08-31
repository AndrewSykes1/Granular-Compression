function [delD, delw] = cidDw3D(r_full, di, D, w, mask, stepScale)
% Safe Newton step for D/w optimization in 3D with local mask
%
% r_full    : 3D radial distance grid
% di        : residual ci - data
% D, w      : current particle diameter and width
% mask      : logical mask for voxels to consider
% stepScale : scale factor for safe step

w_real = 1 / w;
rp = r_full - D/2;
tanh1 = tanh(rp * w_real);
sech2 = sech(rp * w_real).^2;

% derivatives
dipD  = w_real .* sech2 / 4;
dipw  = -rp / 2 .* sech2;
dipDD = w_real^2 / 4 .* tanh1 .* sech2;
dipww = rp.^2 .* tanh1 .* sech2;
dipDw = sech2 .* (1 - 2*w_real*rp.*tanh1) / 4;

% apply mask
dipD  = dipD .* mask;
dipw  = dipw .* mask;
dipDD = dipDD .* mask;
dipww = dipww .* mask;
dipDw = dipDw .* mask;
diMasked = di .* mask;

% gradient and Hessian
chiD  = diMasked .* dipD;
chiw  = diMasked .* dipw;
chiDD = dipD.^2 + diMasked .* dipDD;
chiww = dipw.^2 + diMasked .* dipww;
chiDw = dipD .* dipw + diMasked .* dipDw;

b = [sum(chiD(:)), sum(chiw(:))];
A = [sum(chiDD(:)), sum(chiDw(:));
     sum(chiDw(:)), sum(chiww(:))];

% check conditioning
condA = cond(A);
if condA > 1e6
    factor = 0.1;  % damp step
else
    factor = 1;
end

% compute safe Newton step
delDw = -stepScale * factor * (b * pinv(A));
delD  = delDw(1);
delw  = -w_real * delDw(2) / (w_real + delDw(2));

end