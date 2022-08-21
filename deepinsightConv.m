function [Xtv,model] = deepinsightConv(data,model,varargin)
% [Xtv,model] = deepinsightConv(data,model)
%
% Convert tabular data to images using model description.
%
% Suitable to convert Validation data or Test data
%
% INPUT:
%   data <- d x 1 (a vector)
%           d x 1 x 3 (3D vector)
%           d x n (n samples in a layer) 
%           d x n x layers (n samples in maximum of 3 layers)  
%    where, d=dimension, n=samples
%
%   model <- is generated from deepinsightTab2Img function
%
%   NOTE: if data is for creating a Validation Set and Augmentation of 
%   data is required then provide Labels for this data by typing:
%
%           ('AugSamples' ,k) where k>0 is any number of sample
%                                    augmentation per class.
%
%           This will add k or less than k samples per class to the 
%           existing data.
%
%           with this option, provide Validation Labels by typing:
%
%           ('Labels', Labels), where Labels is categorical input
%
%  [XTr,model] = deepinsightConv(data,model,'AugSamples',k,'Labels',Labels)
%
% OUTPUT:
%   XTr <- *2D array of size R x C for a vector of size d x 1.
%          *3D array of size R x C x layer for a 3D vector (d x 1 x layer).
%          *4D array of size R x C x layers x n for a data of 
%           size d x n x layers.
%   
%  model <- if data is augmented (in case of validation set) then augmented
%  data information can be retrieved from model, such as new validation
%  labels defined in model.ValLabels.
%
%  Ref: DeepInsight projects
%   [1] DeepInsight, 2019, Sci. Rep.
%   [2] DeepFeature, 2021, Breif. in Bioinf.
%   [3] DeepInsight3D, 2022, bioRxiv
%
%  Link: https://alok-ai-lab.github.io/DeepInsight/ 

if nargin<2
    disp('Error: provide `model` with data.');
    disp('Xtv = deepinsightConv(data,model).');
    Xtv=[];model=[];
    return
end
Var={'AugSamples','Labels'};
Default={0,categorical(0)};

data = normalization(data,model);

for dsz = 1:size(data,3)
    for j=1:size(data,2)
        Xtv(:,:,dsz,j) = ConvPixel(data(:,j,dsz),model.xp,model.yp,model.A,model.B,model.Base,0);
    end
end

if length(varargin)>0
model.Validation=struct(Var{1},Default{1},Var{2},Default{2});
Length = 1:length(varargin);
if length(varargin)<4
    disp('Error: insufficient Augment input');
    fprintf(['deepinsightConv(data,model,''AugSamples'',' ...
        'k,''Labels'',Labels);\n']);
    return
else
    for k=1:length(Var)
        inx = Length(strcmpi(varargin,Var{k}));
        if inx>0
            model.Validation = setfield(model.Validation, ...
                Var{k},varargin{inx+1});
        end
    end
    if isa(model.Validation.Labels,'categorical')==0
        model.Validation.Labels=categorical(model.Validation.Labels);
    end
    model.Validation.orgLabels = model.Validation.Labels;
    if numel(model.Validation.Labels)<3
        disp(['number of samples is extremely small ' ...
                'to perform augmentation']);
        return
    else
        [Xtv,model.Validation.Labels] = augmentDeepInsight2(Xtv, ...
            model.Validation.Labels,model.Validation.AugSamples); 
    end
end
end
    
if strcmp(model.Parm.Blurring,'yes')==1
    disp('Blurring technique used');    
    Xtv=BlurTech_samples(Xtv,model,model.Parm.Step);
end
end