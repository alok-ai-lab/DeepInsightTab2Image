function XTrain = BlurTech_samples_p(XTrain,model,STEP)

if nargin==1
    STEP=4;
    parfor j=1:size(XTrain,4)
        MB(:,:,:,j)=BlurTech(XTrain(:,:,:,j));
    end
elseif nargin==2
    STEP=4;
    parfor j=1:size(XTrain,4)
        MB(:,:,:,j)=BlurTech(XTrain(:,:,:,j),model.xp,model.yp);
    end
else
    parfor j=1:size(XTrain,4)
        MB(:,:,:,j)=BlurTech(XTrain(:,:,:,j),model.xp,model.yp,STEP);
    end
end
XTrain=MB;
end
