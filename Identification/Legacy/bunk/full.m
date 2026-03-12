clear('all');
% <trackframe.m> Mark D. Shattuck 3/29/2008
% Particle tracking demonstration

% User Inputs
diameter=12;            % Initial Diameter Guess
width=1.3;              % Initial Width Guess
Cutoff=5;               % minimum peak intensity
MinSep=5;               % minimum separation between peaks

highHist=250;           % highHist and lowHist values come the image histogram
lowHist=10;             % highHist/lowHist=typical pixel value outside/inside

maxDwTicker=10;         % maximum number of calls to cidDw Newton solver.
mindeldiameter=.0001;   % minimum change in diameter before stopping

maxTicker=5;            % maximum number of calls to cidp2 Newton solver.
mindelchi2=1;           % minimum change in chi2 before stopping


% setup for ideal particle
szKern = 2*fix( diameter/2 + 4*width/2 ) -1;                                % size of ideal particle image
halfSzKern = (szKern-1) / 2;                                                % (size-1)/2 of ideal particle image
[xGrid yGrid]=ndgrid(-halfSzKern : halfSzKern,  -halfSzKern : halfSzKern);  % ideal particle image grid
rGrid = hypot(xGrid, yGrid);                                                % radial coordinate


% Load image data
rawImg = imread('test.bmp');                                   % load image
[xLen yLen] = size(rawImg);                                    % image size
normImg = (highHist - double(rawImg)) / (highHist - lowHist);  % normalize image


% find pixel accurate centers using chi-squared
[peakCount xPeakLoc yPeakLoc] = findpeaks(1 ./ chiimg(normImg, ipf(rGrid,diameter,width)), 1, Cutoff, MinSep);  % find maxima

% Minimizing chi-squared for sub-pixel accuracy


% create local grid centered on each particle and overlap matrix
[peakGrids overlap] = pgrid(xPeakLoc - halfSzKern, yPeakLoc - halfSzKern,  xLen,yLen,  [1 xLen 1 yLen], peakCount, 2*halfSzKern+3, 0); 
peakKernels = ipf(peakGrids,diameter,width);     % create calculated image

residuals = peakKernels - normImg;               % Calculate difference image
chi2 = sum(residuals(:).^2);                     % Calculate Chi-Squared (Squared residual difference)
fprintf('Chi-Squared=%f\n',chi2);

% save for later optimized comparison
chi2Initial=chi2;
residualsInitial=residuals;  


% find best diameter and width
ticker=0;
deldiameter=1e99;

% Optimize D and w
while((abs(deldiameter)>mindeldiameter) && (ticker<maxDwTicker))

  % Run newtons method for updated diameters and widths
  [deldiameter delwidth] = cidDw(abs(peakGrids), residuals, diameter, width);
  diameter = diameter + deldiameter;
  width    = width    + delwidth;

  % Create kernels with new better diameters and widths, then find residuals
  peakKernels = ipf(abs(peakGrids), diameter, width);
  residuals =      (peakKernels - normImg);
  
  % Iterate
  fprintf('.');
  ticker=ticker+1;
end
% Print optimization stats
fprintf('\n');
chi2=sum(residuals(:).^2);
fprintf('Chi-Squared=%f\n',chi2);



% Find best positions
ticker=0;
delchi2=1e99;

% Optimize x,y,z
while((abs(delchi2)>mindelchi2) && (ticker<maxTicker))
  
  % Run newtons method for updated positions
  [dxPeakLoc dyPeakLoc]=cidp2(peakGrids,overlap,residuals,peakCount,diameter,width);  %
  xPeakLoc=xPeakLoc+dxPeakLoc;
  yPeakLoc=yPeakLoc+dyPeakLoc;

  % Create new kernels and compute residuals
  [peakGrids overlap]=pgrid(xPeakLoc-halfSzKern,yPeakLoc-halfSzKern,xLen,yLen,[1 xLen 1 yLen],peakCount,2*halfSzKern+3,0); % create local grid centered on each particle and overlap matrix
  peakKernels=ipf(peakGrids,diameter,width);  % create calculated image
  residuals=(peakKernels-normImg);

  % Calculate the error changes
  delchi2=chi2-sum(residuals(:).^2);          % Calculate change in Chi-Squared
  chi2=chi2-delchi2;                          % Calculate Chi-Squared

  % iterate
  fprintf('.');
  ticker=ticker+1;
end
% Print optimization stats
fprintf('\n');
chi2=sum(residuals(:).^2);                    % Calculate Chi-Squared
fprintf('Chi-Squared=%f\n',chi2);


% Plot optimization results
fig=figure(2); set(fig,'Position',[100 100 600 400],'Color',[1 1 1]);
simage([residuals.^2 residualsInitial.^2]); 
caxis([0 .25]); % Show the chi-squared images
title(sprintf('New \\chi^2=%6.2f           Original \\chi^2=%6.2f',chi2,chi2Initial),'fontsize',15)