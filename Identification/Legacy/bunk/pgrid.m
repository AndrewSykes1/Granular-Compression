function [peakGrid,overlap]=pgrid(xPeakLshift,yPeakDshift,xLen,yLen,rectang,peakCount,szKernPad,rad)  
% pgrid  Create a local grid <peakGrid=cx+i*cy> centered on each particle and an overlap matrix <overlap> 
% Usage: [peakGrid,overlap]=pgrid(xPeakLshift,yPeakDshift,xLen,yLen,rectang,peakCount,szKernPad,rad)  
%
% Creates a local grid [see ndgrid] for the Voronoi volume of each peakCount point
% centered at the position specified by xPeakLshift and yPeakDshift.  The union of the
% grids should cover and xLen x yLen image inside the rectangle [rectang].  The
% maximum size of an individual grid is 2*ceil(szKernPad/2).  If rad=1 then return
% abs(peakGrid) instead.  overlap is an image whose value is the index of xPeakLshift/yPeakDshift
% [1:peakCount] at each pixel in the Voronoi volume of each point. 

% revision history:
% 01/16/01 Mark D. Shattuck <mds> calcimg.m  
% 02/30/06 mds rename pgrid.m return peakGrid and overlap instead of ci

if (length(xPeakLshift)==0);
  peakGrid=zeros(xLen,yLen);
  overlap=peakGrid;
  return;
end

yl=rectang(1);
yh=rectang(2);
xl=rectang(3);
xh=rectang(4);

[xGrid yGrid]=ndgrid(1:xLen,1:yLen);
peakGrid=max(xLen,yLen)*ones(xLen,yLen);

overlap=zeros(xLen,yLen);
kernRangeX=-ceil(szKernPad/2):ceil(szKernPad/2);
kernRangeY=kernRangeX;

for peakIndex=1:peakCount
  kernExtRangeX=round(xPeakLshift(peakIndex)) + kernRangeX;
  kernExtRangeY=round(yPeakDshift(peakIndex)) + kernRangeY;
  
  boundedX=kernExtRangeX(find((kernExtRangeX<=xh)&(kernExtRangeX>=xl)));
  boundedY=kernExtRangeY(find((kernExtRangeY<=yh)&(kernExtRangeY>=yl)));

  % If inside rectangle
  if(numel(boundedX) & numel(boundedY))       % particles influence must be inside rectang
    
    if(rad)
      boundedGrid=abs(xGrid(boundedX,boundedY)-xPeakLshift(peakIndex)+i*(yGrid(boundedX,boundedY)-yPeakDshift(peakIndex)));
      [boundLenX boundLenY]=size(boundedGrid);
      [non0X non0Y]=find(peakGrid(boundedX,boundedY)>=boundedGrid);

      overlap(non0X+boundedX(1)-1+xLen*(non0Y+boundedY(1)-2))=peakIndex;
      peakGrid(non0X+boundedX(1)-1+xLen*(non0Y+boundedY(1)-2))=boundedGrid(non0X+boundLenX*(non0Y-1));

    else
      boundedGrid=xGrid(boundedX,boundedY)-xPeakLshift(peakIndex)+i*(yGrid(boundedX,boundedY)-yPeakDshift(peakIndex));
      [boundLenX boundLenY]=size(boundedGrid);
      [non0X non0Y]=find(abs(peakGrid(boundedX,boundedY))>=abs(boundedGrid));

      overlap(non0X+boundedX(1)-1+xLen*(non0Y+boundedY(1)-2))=peakIndex;
      peakGrid(non0X+boundedX(1)-1+xLen*(non0Y+boundedY(1)-2))=boundedGrid(non0X+boundLenX*(non0Y-1));
    end
  end
end