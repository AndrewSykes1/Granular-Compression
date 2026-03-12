function [countAboveCutoff,rowid,colid]=findpeaks(convMap,fillerIs1,CutOff,MinSep)
% findpeaks     Find intensity peaks in a image
% Usage: [countAboveCutoff,rowid,colid]=findpeaks(convMap,mask,CutOff,MinSep)
%
% Finds all pixels in convMap*mask, which are larger than their 8 nearest
% neighbors and have intensities greater than 'Cutoff' and are separated
% from all other peaks by at least 'MinSep' pixels.  
%
% revision history:
% 02/24/01 Mark D. Shattuck <mds> chiimg.m  
% 03/21/03 mds added mask
% 04/03/03 mds change implementation of mask
% 10/02/07 mds added MinSep
% 07/18/08 mds added sort by peak height;


[xLen yLen]=size(convMap);

peakPixels = fillerIs1;
for nPix=-1:1                 % For x pixels around point
  for mPix=-1:1               % For y pixels around point
    if(~(mPix==0 && nPix==0)) % If not center pixel
      peakPixels=(convMap>convMap(rem((1:xLen)+xLen+nPix-1,xLen)+1,rem((1:yLen)+yLen+mPix-1,yLen)+1)) & peakPixels;
    end
  end
end
% Find pixels that have neighbors that are all dimmer than itself

peaksAboveCutoff=find((convMap(:).*peakPixels(:))>CutOff); % Find peak pixels above threshold
countAboveCutoff=length(peaksAboveCutoff);

[rowid colid]=ind2sub([xLen yLen],peaksAboveCutoff);
[junk index]=sort(convMap(peaksAboveCutoff));

peakArr=repmat(rowid(index)+i*colid(index),1,countAboveCutoff);
transSubtract=abs(peakArr.'-peakArr);

truePeaks=index((sum(tril(transSubtract<MinSep & transSubtract~=0)))~=0);

peaksAboveCutoff=peaksAboveCutoff(setdiff(1:countAboveCutoff,truePeaks));
[junk index]=sort(convMap(peaksAboveCutoff),'descend');

countAboveCutoff=length(peaksAboveCutoff);
[rowid colid]=ind2sub([xLen yLen],peaksAboveCutoff(index));

% rowid and colid are valid peaks that have passed through this weird algorithm
% and have been found to be valid


