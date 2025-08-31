function [Npf, spx, spy, spz] = findpeaks3D(img, mk, CutOff, MinSep)
% findpeaks3D  Find intensity peaks in a 3D image
%
% img    : 3D image
% mk     : mask (same size as img)
% CutOff : minimum intensity threshold
% MinSep : minimum separation between peaks (voxels)
%
% Npf : number of peaks
% spx, spy, spz : coordinates of peaks

if nargin < 2 || isempty(mk)
    mk = true(size(img));
end

% Find local maxima (26 neighbors)
localMax = imregionalmax(img) & mk;

% Apply intensity cutoff
localMax = localMax & (img > CutOff);

% Get linear indices
idx = find(localMax);
[spx, spy, spz] = ind2sub(size(img), idx);

% Sort by intensity descending
[~, sortIdx] = sort(img(idx), 'descend');
spx = spx(sortIdx);
spy = spy(sortIdx);
spz = spz(sortIdx);

% Enforce minimum separation
keep = true(length(spx), 1);
for i = 1:length(spx)
    if ~keep(i), continue; end
    dx = spx - spx(i);
    dy = spy - spy(i);
    dz = spz - spz(i);
    dist = sqrt(dx.^2 + dy.^2 + dz.^2);
    tooClose = dist < MinSep & dist > 0;
    keep(tooClose) = false;
end

% Filter peaks
spx = spx(keep);
spy = spy(keep);
spz = spz(keep);
Npf = length(spx);

end
