function [cr, over] = pgrid3D(spx, spy, spz, Nx, Ny, Nz, Np, radLen, rad)
% pgrid3D  Create local grids around each particle and overlap matrix
%
% rad==1: cr = scalar distance
% rad==0: cr = struct with x,y,z vector differences

% Initialize
over = zeros(Nx, Ny, Nz);
if isempty(spx)
    if rad
        cr = zeros(Nx, Ny, Nz);
    else
        cr = struct();
        cr.x = zeros(Nx, Ny, Nz);
        cr.y = zeros(Nx, Ny, Nz);
        cr.z = zeros(Nx, Ny, Nz);
    end
    return;
end

% Initialize cr
if rad
    cr = max([Nx, Ny, Nz]) * ones(Nx, Ny, Nz);
else
    cr = struct();
    cr.x = zeros(Nx, Ny, Nz);
    cr.y = zeros(Nx, Ny, Nz);
    cr.z = zeros(Nx, Ny, Nz);
end

llRange = -radLen:radLen;
kkRange = -radLen:radLen;
mmRange = -radLen:radLen;

for np = 1:Np
    ll = round(spx(np)) + llRange; ll = ll(ll >= 1 & ll <= Nx);
    kk = round(spy(np)) + kkRange; kk = kk(kk >= 1 & kk <= Ny);
    mm = round(spz(np)) + mmRange; mm = mm(mm >= 1 & mm <= Nz);
    
    if isempty(ll) || isempty(kk) || isempty(mm)
        continue;
    end

    [XX, YY, ZZ] = ndgrid(ll, kk, mm);
    
    if rad
        X = sqrt((XX - spx(np)).^2 + (YY - spy(np)).^2 + (ZZ - spz(np)).^2);
        mask = cr(ll, kk, mm) >= X;
        ind = find(mask);
        over(sub2ind([Nx, Ny, Nz], XX(ind), YY(ind), ZZ(ind))) = np;
        cr(sub2ind([Nx, Ny, Nz], XX(ind), YY(ind), ZZ(ind))) = X(ind);
    else
        crx = XX - spx(np);
        cry = YY - spy(np);
        crz = ZZ - spz(np);
        dist = sqrt(crx.^2 + cry.^2 + crz.^2);
        mask = sqrt(cr.x(ll,kk,mm).^2 + cr.y(ll,kk,mm).^2 + cr.z(ll,kk,mm).^2) >= dist;
        ind = find(mask);
        over(sub2ind([Nx, Ny, Nz], XX(ind), YY(ind), ZZ(ind))) = np;
        cr.x(sub2ind([Nx, Ny, Nz], XX(ind), YY(ind), ZZ(ind))) = crx(ind);
        cr.y(sub2ind([Nx, Ny, Nz], XX(ind), YY(ind), ZZ(ind))) = cry(ind);
        cr.z(sub2ind([Nx, Ny, Nz], XX(ind), YY(ind), ZZ(ind))) = crz(ind);
    end
end
end
