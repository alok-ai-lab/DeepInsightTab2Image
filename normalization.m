function [Parm,model] = normalization(Parm,model)
% [Parm,model] = normalization(Parm)
%  (when using training data)
%
% data = normalization(data,model);
% (when using test or validation data).
%
% Norm-1 or Norm-2 as per DeepInsight, 2019 paper

if nargin==1
    layer=size(Parm.Xtrain,3);
elseif nargin==2
    data = Parm;
    clear Parm
    Parm.Norm = model.Parm.Norm;
    layer = model.C;
end


switch Parm.Norm
    case 1
    fprintf('\nNORM-1\n');
    %########### Norm-1 ###################
    for dsz=1:layer
        if nargin==1
            model.Max{dsz}=max(Parm.Xtrain(:,:,dsz)')';
            model.Min{dsz}=min(Parm.Xtrain(:,:,dsz)')';
            Parm.Xtrain(:,:,dsz)=(Parm.Xtrain(:,:,dsz)-model.Min{dsz})./(model.Max{dsz}-model.Min{dsz});
        else
            data(:,:,dsz) = (data(:,:,dsz)-model.Min{dsz})./(model.Max{dsz}-model.Min{dsz});
        end
    end
    if nargin==1
        Parm.Xtrain(isnan(Parm.Xtrain))=0;
    else
        data(isnan(data))=0;
        data(data>1)=1;
        data(data<0)=0;
    end
   
    
    case 2
    fprintf('\nNORM-2\n');
    %########### Norm-2 ###################
    for dsz=1:layer
        if nargin==1
            model.Min{dsz}=min(Parm.Xtrain(:,:,dsz)')';
            Parm.Xtrain(:,:,dsz)=log(Parm.Xtrain(:,:,dsz)+abs(model.Min{dsz})+1);
        else
    
            indV = data(:,:,dsz)<model.Min{dsz};
            for j=1:length(model.xp)
                data(j,indV(j,:),dsz)=model.Min{dsz}(j); 
                %Parm.Xtest(j,indT(j,:),dsz)=model.Min{dsz}(j);
            end
            data(:,:,dsz) = log(data(:,:,dsz)+abs(model.Min{dsz})+1);
        end
        %Parm.Xtest(:,:,dsz)=log(Parm.Xtest(:,:,dsz)+abs(model.Min)+1);
        if nargin==1
            model.Max{dsz}=max(max(Parm.Xtrain(:,:,dsz)));
            Parm.Xtrain(:,:,dsz)=Parm.Xtrain(:,:,dsz)/model.Max{dsz};
        else
            data(:,:,dsz) = data(:,:,dsz)/model.Max{dsz};
            %Parm.Xtest(:,:,dsz) = Parm.Xtest(:,:,dsz)/model.Max;
        end
    end
    if nargin==2
        data(data>1)=1;
        %Parm.Xtest(Parm.Xtest>1)=1;
    end
end

if nargin==2
    Parm=data;
    if nargout==2
        disp('Warning: model file is from deepinsightTab2Img!');
        disp(['The function deepinsighConv does not provide a new ' ...
            'model struct!']);
    end
end
