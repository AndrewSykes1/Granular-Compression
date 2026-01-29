function [chiimg Wip2]=chiimg(img,kernel,W,Wip2,outputShape)
% chiimg     Calculate chi-squared image
% Usage: [chiimg Wip2]=chiimg(img,kernel,W,Wip2,outputShape);
%
% Calculates an image of chi-squared of the form 
% chiimg=int(W(x-x0)(img(x)-kernel(x-x0))^2 dx) using convolution.  Chi-squared
% is an image which can be larger than (outputShape=='full'[default]), smaller
% than (outputShape=='valid'), or the same size as (outputShape='same') the input image
% img. chiimg is minimum where img and the test image kernel are most alike in
% a squared-difference sense.  W ([default]W==kernel) limits the area to be
% consider by weighting chiimg.  

% revision history:
% 08/04/00 Mark D. Shattuck <mds> chiimg.m  
% 01/30/04 mds added return Wip2
% 02/22/04 mds added outputShape option
% 09/22/07 mds update for non symmetric W and Ip


if(~exist('outputShape','var'))
  outputShape='full';
end
if(~exist('Wip2','var') || isempty(Wip2))  % Wip2 can be pre calculated since it does not depend on img
  blank=ones(size(img));                     % Blank image
  Wip2=(conv2(blank,kernel.^2.*W,outputShape));        % Weighting factor
end


% If provided a kernel, assume for all cases
if(~exist('W','var') || isempty(W))
  Wkern=kernel;
end


kernel=kernel(end:-1:1,end:-1:1);  % Flip for convolution
Wkern=Wkern(end:-1:1,end:-1:1);    % Flip for convolution

chiimg=1+(-2*conv2(img,kernel.*Wkern,outputShape)+conv2(img.^2,Wkern,outputShape))./Wip2;    % best fit ignoring overlap  

% Create a convolved image using the chi squared formula
