function [XTrain,model] = imageTransformer(Parm)
%XTrain = imageTransformer(Parm)
%
% XTrain is a 4D array

if strcmp(Parm.SnowFall,'yes')==1
    Parm.MPS_Fix=0;
    Parm.SnowFall_A = Parm.PixelSize;
    Parm.SnowFall_B = Parm.PixelSize;
    Parm.Max_Px_Size = 1e+5;%inf;  % inf gives precision error if data values are very large eg 1e+17
end

[Parm,model] = normalization(Parm);

[XTrain,model] = prepareData(Parm,model);

if strcmp(Parm.Augment,'yes')
    model.orgLabels = Parm.Labels;
    [XTrain,model.Labels] = augmentDeepInsight2(XTrain,Parm.Labels,Parm.AugSamples); 
end
    
if strcmp(Parm.Blurring,'yes')==1
    disp('Blurring technique used');    
    XTrain=BlurTech_samples(XTrain,model,Parm.Step);
end
    
end

