function [XTrain,model] = deepinsightTab2Img(varargin)
% [XTrain,model] = deepinsightTab2Img(data,options)
%
% This code transforms a tabular data to image data for convolution
% neural network (CNN) applications. 
% 
% INPUT: Tabular data of format d x n x layers (where d=dimension or 
% number of elements, n=samplpes, and layers=1 to 3); i.e. row are elements
% or features, and columns are samples.
%
% OUTPUT: A 4D array, XTrain of size R x C x layers x n, where R is the 
% number of rows and C is the number of columns of an image.
%
%         model <- parameters stored in model struct.
%
% Tabular data with 1-Layer will produce a gray scale image and with 
% 3-Layer will produce a colored image.
%
% ------------------ Example 1 ------------------ 
% Usage 1:
% create a random data
% 
% data = rand(5,10);
% here dimensionality of data is d=5, and number of samples, n=10.
% XTrain = deepinsightTab2Img(data);
%   size of XTrain is 224 x 224 x 1 x 10 (image size is 224 x 224)
%
% Usage 2:
% modifying options
% XTrain = deepinsightTab2Img(data,'Method','umap');
%
% This will change the default option of Method to 'umap' and the
% projection will be done by umap.
%
% Usage 3.
% [XTrain,model] = deepinsightTab2Img(data);
% XTrain will be same as of Usage1 and model will give details of options
% used, location of characteristic pixels, and parameters for
% normalization. 
% ------------------------------------------------
%
% ----------------- Default options --------------
% The default options used are:
% 'Method'='umap'
% 'Dist'='euclidean';
% 'Labels'=[]
% 'PixelSize'=224 x 224
% 'Norm'=2
% 'Augment'='no'
% 'AugSamples'=500 (used only when 'Augment'='yes')
% 'FeatureMap'=1
% 'Blurring'='no'
% 'SnowFall'='no'
% 'Step'=4
% -------------------------------------------------
%
% --------------- Details of options --------------
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
% -------------------------------------------------
%
% -------------- Using various options ------------
%
% [XTrain,model] = deepinsightTab2Img(data,'Method',<method_opt>,...
%   'Dist',<dist_opt>,'Labels',<label_opt>, PixelSize,<psize_opt>,...
%   'Norm',<norm_opt>,'Augment',<aug_opt>,'AugSamples',<asamples_opt>,
%   'FeatureMap',<fm_opt>,'Blurring',<blur_opt>,'SnowFall',<snowfall_opt>);
%
% see above for option details
%  'Method' = 'tsne' | 'pca'| 'kpca'| 'umap' | 'lda'
%
% 'lda' option requires class Labels
%
% ********* e.g. lda option (supervised projection) 
% data = rand(5,10);
% Labels = [ones(4,1); ones(6,1)*2];
% [XTrain,model] = deepinsightTab2Img(data,'Method','lda','Labels',Labels);
%
% If Method = tsne then provide 'Dist' option from 'Details of options'
% described above. Default Dist is 'euclidean'.
%
% ********* e.g. Dist, PixelSize, Augment
% [XTrain,model] = deepinsightTab2Img(data,'Dist','cosine');
% for this case, 'Method' is default; i.e. 'tsne' and 'Dist' is 'cosine';
%
% [XTrain,model] = deepinsightTab2img(data,'PixelSize',[]);
%  in this case, PixelSize will be automatically determined.
% 
% [XTrain,model] = deepinsightTab2Img(data,'Augment','yes',...
%                     'AugSamples',20,'Labels',Labels);
%  in this case, each class will be augmented by 20 or less than 20 samples.
%
% **********  e.g. FeatureMap
% If 3 layers of data are simulatenously used for projection then use the
% following option:
%
% data = rand(5,10,3);
%
% [XTrain,model] = deepinsightTab2Img(data,'FeatureMap',0);
%
% if only Layer-2 is needed for projection and the remaining layers for
% mapping then use
% [XTrain,model] = deepinsightTab2Img(data,'FeatureMap',2);
%   note default 'FeatureMap' is 1.
%
% ************ e.g. blurring technique
%
% [XTrain,model] = deepinsightTab2Img(data,'blurring','yes');
%   The nearby pixels of characteristic pixels will be blurred. This has
%   shown to improve the classification performance of CNN model. Also very
%   useful when the data is sparse.
%
%  Default Step = 4, you can change Step between 1 and 5 by calling option
%  [XTrain,model] = deepinsightTab2Img(data,'Blurring','yes',...
%                       'Step',<step_opt>);
%  where, <step_opt> = 1 or 2 or 3 or 4 or 5 
%
% ************* e.g. SnowFall technique
% First introduced in DeepFeature method. It tries to reduce the size of
% pixel framework by moving the characteristic pixels towards the center.
%
% [XTrain,model] = deepinsightTab2Img(data,'SnowFall','yes');
%   if pixel framework is larger than the framework as determined by the
%   SnowFall algorithm then only PixelSize will be used to fix the size.
%
% Link: https://alok-ai-lab.github.io/DeepInsight/ 

Parm = define_variables(varargin);
if isempty(Parm)==1
    disp('Please check errors and try again!');
    XTrain=[];
    model=[];
    return
end

[XTrain,model]=imageTransformer(Parm);
Parm=rmfield(Parm,'Xtrain');
model.Parm = Parm;

end


