function XTrain = BlurTech_samples(XTrain,model,STEP)
% XTrain = BlurTech_samples(XTrain,model,STEP)
%
% Input: XTrain 4D array in the format R x C x layer x n
%           R is number of rows and C is number of columns
%           layer is between [1,3] and n is the number of samples
%
%        input is a single gray scale image then XTrain = R x C
%                     (in this case layer=1 and n=1)
%
% model <- derived from deepinsightTab2Img function. It is the location of
% characteristic pixels; i.e., model.xp and model.yp (row and column
% locations).
%
% STEP <- by default, STEP=4. However, it can be changed betweeen [1,5].
%        
% Output: Out using blurring of nearby pixels
if nargin==1
	XTrain = BlurTech_samples_p(XTrain);
elseif nargin==2
	XTrain = BlurTech_samples_p(XTrain,model);
else
	XTrain = BlurTech_samples_p(XTrain,model,STEP);
end
	
end

