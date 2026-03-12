function ipi=ipf(radialGrid,diameter,width)
% ipf    Calculate ideal particle image. 
% Usage: ipi=ipf(radialGrid,diameter,width)
%
% Calculates an ideal particle image ipi.  The particle has diameter and
% width parameter width.  2width is the width of 76% of the fall off.

% revision history:
% 08/04/05 Mark D. Shattuck <mds> ipf.m  
% 01/30/06 mds added abs(radialGrid)
% 04/30/07 mds made w a true measure of width.

ipi= (1-tanh( ( abs(radialGrid)- diameter/2 ) / width)) / 2;

% Creates the kernel