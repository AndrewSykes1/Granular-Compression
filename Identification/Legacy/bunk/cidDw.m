function [delD delw]=cidDw(peakGrids,residuals,diameter,width)  
% cidDw    Calculate one Newton's step toward minimizing residuals^2 over diameter and width. 
% Usage: [dpx,dpy]=cidDw(cxy,residuals,diameter,width)  
%
% Calculates change in diameter and width needed to move residuals^2 closer to a minimum.  

% revision history:
% 09/14/00 Mark D. Shattuck <mds> cidDw.m  
% 4/30/07 mds changed meaning of width to 1/width


% Create general params
particleKern = peakGrids - diameter/2;
width=1/width;
hessian=zeros(2,2);

% Create starter functions
tanh1 = tanh(particleKern * width);
sech2 = sech(particleKern * width).^2;

% First Partial derivatives
dipD  =  width           .* sech2/4;
dipw  = -particleKern/2  .* sech2;

% Second Partial derivatives
dipDD =  width^2/4        * tanh1 .* sech2;
dipww =  particleKern.^2 .* tanh1 .* sech2;
dipDw =  sech2           .* (1-2*width * particleKern .* tanh1) /4 ;

% Gradient of "cost function"
chiD  = residuals .* dipD;
chiw  = residuals .* dipw;

% Approx. Hessian of "cost function"
chiDD = dipD.^2    + residuals .* dipDD;
chiww = dipw.^2    + residuals .* dipww;
chiDw = dipD      .* dipw + residuals .* dipDw;

% Fill out approx. Hessian
deltaArr=[sum(chiD(:)) sum(chiw(:))];
hessian(1,1)=sum(chiDD(:));
hessian(1,2)=sum(chiDw(:));
hessian(2,1)=hessian(1,2);
hessian(2,2)=sum(chiww(:));

% Solves for parameter updates
delDw = -deltaArr * pinv(hessian);
delD  =  delDw(1);
delw  = -width*delDw(2) / (width+delDw(2));
