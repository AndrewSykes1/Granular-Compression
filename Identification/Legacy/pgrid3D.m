function [cr, overlap] = pgrid3D(xPeak, yPeak, zPeak, xLen, yLen, Nz, Np, radLen, rad)
% pgrid3D  Create local grids around each particle and overlap matrix
%
% rad==1: cr = scalar distance
% rad==0: cr = struct with x,y,z vector differences

% Initialize
overlap = zeros(xLen, yLen, Nz);
if isempty(xPeak)
    if rad
        cr = zeros(xLen, yLen, Nz);
    else
        cr = struct();
        cr.x = zeros(xLen, yLen, Nz);
        cr.y = zeros(xLen, yLen, Nz);
        cr.z = zeros(xLen, yLen, Nz);
    end
    return;
end

% Initialize cr
if rad
    cr = max([xLen, yLen, Nz]) * ones(xLen, yLen, Nz);
else
    cr = struct();
    cr.x = zeros(xLen, yLen, Nz);
    cr.y = zeros(xLen, yLen, Nz);
    cr.z = zeros(xLen, yLen, Nz);
end

llRange = -radLen:radLen;
kkRange = -radLen:radLen;
mmRange = -radLen:radLen;

for np = 1:Np
    ll = round(xPeak(np)) + llRange; ll = ll(ll >= 1 & ll <= xLen);
    kk = round(yPeak(np)) + kkRange; kk = kk(kk >= 1 & kk <= yLen);
    mm = round(zPeak(np)) + mmRange; mm = mm(mm >= 1 & mm <= Nz);
    
    if isempty(ll) || isempty(kk) || isempty(mm)
        continue;
    end

    [XX, YY, ZZ] = ndgrid(ll, kk, mm);
    
    if rad
        X = sqrt((XX - xPeak(np)).^2 + (YY - yPeak(np)).^2 + (ZZ - zPeak(np)).^2);
        mask = cr(ll, kk, mm) >= X;
        ind = find(mask);
        overlap(sub2ind([xLen, yLen, Nz], XX(ind), YY(ind), ZZ(ind))) = np;
        cr(sub2ind([xLen, yLen, Nz], XX(ind), YY(ind), ZZ(ind))) = X(ind);
    else
        crx = XX - xPeak(np);
        cry = YY - yPeak(np);
        crz = ZZ - zPeak(np);
        dist = sqrt(crx.^2 + cry.^2 + crz.^2);
        mask = sqrt(cr.x(ll,kk,mm).^2 + cr.y(ll,kk,mm).^2 + cr.z(ll,kk,mm).^2) >= dist;
        ind = find(mask);
        overlap(sub2ind([xLen, yLen, Nz], XX(ind), YY(ind), ZZ(ind))) = np;
        cr.x(sub2ind([xLen, yLen, Nz], XX(ind), YY(ind), ZZ(ind))) = crx(ind);
        cr.y(sub2ind([xLen, yLen, Nz], XX(ind), YY(ind), ZZ(ind))) = cry(ind);
        cr.z(sub2ind([xLen, yLen, Nz], XX(ind), YY(ind), ZZ(ind))) = crz(ind);
    end
end
end
