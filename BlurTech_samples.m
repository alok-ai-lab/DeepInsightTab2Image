function XTrain = BlurTech_samples(XTrain,model,STEP)
% Input: 4D array
%        
% Output: Out using blurring of nearby pixels

parfor j=1:size(XTrain,4)
    MB(:,:,:,j)=BlurTech(XTrain(:,:,:,j),model.xp,model.yp,STEP);
end
XTrain=MB;
end

