function [dpx, dpy, dpz] = cidp23D(cxyz, over, di, Np, D, w)
% cidp23D  One Newton step to minimize di^2 over particle centers in 3D
%
% Inputs:
%   cxyz : struct with fields x,y,z (distance grids of size [Ny, Nx, Nz])
%   over : 3D overlap matrix, each voxel indicates owning particle
%   di   : 3D residual (ci - data)
%   Np   : number of particles
%   D    : current particle diameter
%   w    : width parameter
%
% Outputs:
%   dpx, dpy, dpz : Nx1 vectors of particle position updates

% Convert w to “real” width as in Shattuck code
w = 1 / w;

maxdr = 2; % limit step size

dpx = zeros(Np,1);
dpy = zeros(Np,1);
dpz = zeros(Np,1);

% Precompute useful quantities
rr = sqrt(cxyz.x.^2 + cxyz.y.^2 + cxyz.z.^2) + eps;  % distance grid
xx = cxyz.x;
yy = cxyz.y;
zz = cxyz.z;

tanh1 = tanh((rr - D/2) * w);
sech2 = sech((rr - D/2) * w).^2;

% First derivatives
dipx = -w * xx .* sech2 ./ (2*rr);
dipy = -w * yy .* sech2 ./ (2*rr);
dipz = -w * zz .* sech2 ./ (2*rr);

% Second derivatives
dipxx = w * sech2 .* (2*w*xx.^2.*rr.*tanh1 - yy.^2 - zz.^2) ./ (2*rr.^3);
dipyy = w * sech2 .* (2*w*yy.^2.*rr.*tanh1 - xx.^2 - zz.^2) ./ (2*rr.^3);
dipzz = w * sech2 .* (2*w*zz.^2.*rr.*tanh1 - xx.^2 - yy.^2) ./ (2*rr.^3);
dipxy = w * xx .* yy .* sech2 .* (2*w*rr.*tanh1 + 1) ./ (2*rr.^3);
dipxz = w * xx .* zz .* sech2 .* (2*w*rr.*tanh1 + 1) ./ (2*rr.^3);
dipyz = w * yy .* zz .* sech2 .* (2*w*rr.*tanh1 + 1) ./ (2*rr.^3);

% Flatten for indexing
overVec = over(:);
diVec = di(:);
xxVec = xx(:);
yyVec = yy(:);
zzVec = zz(:);
dipxVec = dipx(:);
dipyVec = dipy(:);
dipzVec = dipz(:);
dipxxVec = dipxx(:);
dipyyVec = dipyy(:);
dipzzVec = dipzz(:);
dipxyVec = dipxy(:);
dipxzVec = dipxz(:);
dipyzVec = dipyz(:);

% Loop over particles
for np = 1:Np
    idx = find(overVec == np); % voxels belonging to this particle

    b = [sum(diVec(idx).*dipxVec(idx)), ...
         sum(diVec(idx).*dipyVec(idx)), ...
         sum(diVec(idx).*dipzVec(idx))];

    A = [sum(dipxVec(idx).^2 + diVec(idx).*dipxxVec(idx)), sum(dipxVec(idx).*dipyVec(idx) + diVec(idx).*dipxyVec(idx)), sum(dipxVec(idx).*dipzVec(idx) + diVec(idx).*dipxzVec(idx));
         sum(dipxVec(idx).*dipyVec(idx) + diVec(idx).*dipxyVec(idx)), sum(dipyVec(idx).^2 + diVec(idx).*dipyyVec(idx)), sum(dipyVec(idx).*dipzVec(idx) + diVec(idx).*dipyzVec(idx));
         sum(dipxVec(idx).*dipzVec(idx) + diVec(idx).*dipxzVec(idx)), sum(dipyVec(idx).*dipzVec(idx) + diVec(idx).*dipyzVec(idx)), sum(dipzVec(idx).^2 + diVec(idx).*dipzzVec(idx))];

    lambda = 1e-6;
    dp = b * pinv(A + lambda * eye(3));  % Newton step
    % Limit step size
    stepMag = norm(dp);
    if stepMag > maxdr
        dp = dp / stepMag * maxdr;
    end

    dpx(np) = dp(1);
    dpy(np) = dp(2);
    dpz(np) = dp(3);
end
end
