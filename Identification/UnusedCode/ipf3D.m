function ipi = ipf3D(cr, D, w)
% ipf3D  Calculate ideal 3D particle image.
% Usage: ipi = ipf3D(cr, D, w)
%
% cr : 3D radial distance array from particle center
% D  : particle diameter
% w  : width parameter
%
% Output:
% ipi : 3D ideal particle image

ipi = (1 - tanh((abs(cr) - D/2) / w)) / 2;

end