function [XTrain,model] = prepareData(Parm,model)
% [XTrain,model] = prepareData(Parm)

Q.Method=Parm.Method;
if strcmp(lower(Q.Method),'lda')==1
    Q.Labels=Parm.Labels;
end
Q.Max_Px_Size = Parm.PixelSize;
Q.SnowFall = double(strcmp(Parm.SnowFall,'yes'));
if any(strcmp('Dist',fieldnames(Parm)))==1
    Q.Dist=Parm.Dist;
end
if Q.SnowFall==1
    Q.SnowFall_A = Parm.SnowFall_A;
    Q.SnowFall_B = Parm.SnowFall_B;
end
Q.z=1; % if Q.z=1 then z values will be output and snow-fall will not be used.
if Parm.FeatureMap==0
    disp('multi-layered data used for Cart2Pixel');
    for dsz=1:size(Parm.Xtrain,3)
        Q.data = Parm.Xtrain(:,:,dsz);
        if Parm.MPS_Fix==1
            [model.z{dsz}] = Cart2Pixel(Q,Q.Max_Px_Size,Q.Max_Px_Size);
        else
            [model.z{dsz}] = Cart2Pixel(Q);
        end
        model.z{dsz} = (model.z{dsz} - min(min(model.z{dsz})))/(max(max(model.z{dsz}))-min(min(model.z{dsz})));
    end
    model.z = cell2mat(model.z);
    Q.data = model.z;
    model = rmfield(model,'z');
end

Q.z=0;
if Parm.FeatureMap>0
    switch Parm.FeatureMap
        case 1
            disp('Layer-1 data used for Cart2Pixel');
        case 2
            disp('Layer-2 data used for Cart2Pixel');
        case 3
            disp('Layer-3 data used for Cart2Pixel');
    end
    Q.data = Parm.Xtrain(:,:,Parm.FeatureMap); 
end
if Parm.MPS_Fix==1
    [tmp,model.xp,model.yp,model.A,model.B,model.Base] = Cart2Pixel(Q,Q.Max_Px_Size,Q.Max_Px_Size);
else
    [tmp,model.xp,model.yp,model.A,model.B,model.Base] = Cart2Pixel(Q);
end

fprintf('\n Pixels: %d x %d\n',model.A,model.B);
clear Q

for dsz = 1:size(Parm.Xtrain,3)
    for j=1:size(Parm.Xtrain,2)
        XTrain(:,:,dsz,j) = ConvPixel(Parm.Xtrain(:,j,dsz),model.xp,model.yp,model.A,model.B,model.Base,0);
    end
end
Parm.Xtrain=[];

model.C = size(XTrain,3);

end

