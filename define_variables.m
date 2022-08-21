function Parm = define_variables(varargin)
% Parm = define_variable(varargin)
%
% data or Xtrain <- A matrix of size d x n (single layer) 
%                                 or d x n x 2 (double layer)
%                                 or d x n x 3 (for 3D layer)
%
% Method <- 1) tsne 2) kpca 3) pca 4) umap 5) lda
%
% Dist <- if Method is 'tsne' select one of these distances
%          'euclidean' (default)| 'seuclidean' | 'cityblock'|'chebychev'|
%          'minkowski'| 'mahalanobis' | 'cosine' | 'correlation' |
%          'spearman' | 'hamming' | 'jaccard' | function handle
%
% Lables <- class labels for 'lda' option and 'Augment' data option
%
% PixelSize <- if PixelSize = N then image size will be N x N 
%                          or N x N x layers (where layers = 1 or 2 or 3)
%
%              if PixelSize = [] then image size will be determined
%              automatically.
%
% Norm <- either '1' for Norm-1 or '2' for Norm-2 (see DeepInsight,2019)
%
% Augment<- 'no' (default) | 'yes' (class-wise augmentation, Labels needed)
%                                   
% AugSamples <- if Augment is 'yes' then 500 per class (default).
%
% FeatureMap <- '0' to simulatenously use all the available layers or
%               multi-omics data for projection.
%
%               '1' to use layer-1 for projection and other layers for
%               mapping only.
%
%               '2' to use layer-2 for projection and other layers for
%               mapping only.
%
%               '3' to use layer-3 for projection and other layers for
%               mapping only.
%
% Blurring <-  'no' (default) | 'yes'
%               Blurring technique will populate nearby pixels of a
%               characteristic pixels. It has been shown that applying
%               blurring technique improves the classification performance
%               of convolutional neural network (CNN) significantly.
%
%   Ref: Manuel C-Cara et al., 2022, A deep learning approach using
%   blurring image technique for bluetooth-based indoor localisation
%   http://dx.doi.org/10.2139/ssrn.4180099
%
%   In this work, a variant of Blurring technique has been used, where
%       1) intensity = 1/(sqrt(e)^(step-1)) is used. 
%       2) overlapping of populated pixels are replaced by Maximum value
%       3) characteristics pixels are not blurred.
%       4) A maximum of Step=4 has been used. However, one can change up to
%       Step=5. 
%   e.g. 'Step',5
%
% SnowFall <- 'no' (default) | 'yes' 
% 
%  REF: Sharma A et al., 2021, DeepFeature, Briefings in Bioinformatics
%  for details about SnowFall algorithm https://doi.org/10.1093/bib/bbab297
%
%  REF: Sharma A et al., 2019, DeepInsight, Scientific Reports
%  https://doi.org/10.1038/s41598-019-47765-6
%
%  REF: Sharma A et al., 2022, DeepInsight-3D, bioRxiv
%  https://doi.org/10.1101/2022.07.14.500140

varargin=varargin{:};
Length = 1:length(varargin);

Var={'Xtrain','Method','Dist','Labels','PixelSize','Norm','Augment',...
    'AugSamples','FeatureMap','Blurring','SnowFall','Step'};
%default
Default={[],'tsne','euclidean',[],224,2,'no',500,1,'no','no',4};
Parm = struct(Var{1},Default{1},Var{2},Default{2},Var{3},Default{3},...
    Var{4},Default{4},Var{5},Default{5},Var{6},Default{6},...
    Var{7},Default{7},Var{8},Default{8},Var{9},Default{9},...
    Var{10},Default{10},Var{11},Default{11},Var{12},Default{12});

if size(varargin{1},1) <3
    disp('data dimensonality is insufficient!');
    disp('The number of elements/features should be more than 2.');
    Parm=[];
    return
end
if size(varargin{1},2) <3
    disp('number of samples is insufficient!');
    Parm=[];
    return
end
Parm.Xtrain=varargin{1};

for k=2:length(Var);
    inx = Length(strcmpi(varargin,Var{k}));
    if inx>1
        Parm = setfield(Parm,Var{k},varargin{inx+1});
    end
end

all_methods={'tsne','kpca','pca','umap','lda'};
if sum(strcmpi(all_methods,Parm.Method))==0
    fprintf('\nThis method, %s,does not exit\n',Parm.Method);
    fprintf('Acceptable methods are:\n');
    fprintf('1) tsne 2) kpca 3) pca 4) umap 5) lda\n');
    fprintf('Note lda is a supervised method and class labels are needed!\n');
    Parm=[];
    return
end
if strcmp('lda',Parm.Method)==1
    [rowLabels,colLabels]=size(Parm.Labels);
    Parm.Labels=categorical(Parm.Labels);
    if colLabels>rowLabels
        Parm.Labels=Parm.Labels';
    end
    if size(Parm.Labels,1)~=size(Parm.Xtrain,2)
        disp('Mismatch of Labels and data!');
        disp(['Number of columns of data and ' ...
            'number of labels should be the same.']);
        Parm=[];
        return
    end
end
if strcmp('yes',Parm.Augment)==1
    [rowLabels,colLabels]=size(Parm.Labels);
    Parm.Labels=categorical(Parm.Labels);
    if colLabels>rowLabels
        Parm.Labels=Parm.Labels';
    end
    if size(Parm.Labels,1)~=size(Parm.Xtrain,2)
        disp('Mismatch of Labels and data!');
        disp(['Number of columns of data and ' ...
            'number of labels should be the same.']);
        disp('Augment requires class Labels!');
        disp('Labels are not required for projection but to augment N samples per class.')
        Parm=[];
        return
    end
end
if isempty(Parm.PixelSize)==1
    Parm.MPS_Fix=0;
else
    Parm.MPS_Fix=1;
end
if Parm.Step>5 || Parm.Step<1
    disp('Step values should be between 1 and 5.')
end
if strcmp(Parm.Blurring,'no')==1
    if any(strcmpi(varargin,'Step'))==1
        fprintf('\n');
        disp(['Warning: Step value will not be considered as Blurring ' ...
            'is set as `no`']);
        disp('Change setting of Blurring to `yes` to apply Step values.');
    end
end