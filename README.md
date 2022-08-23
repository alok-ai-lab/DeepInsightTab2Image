# DeepInsightTab2Image
DeepInsight Tab2Image coder: a simple and easy way of converting tabular data to images for convolutional neural networks (CNNs). Improvements are added. `One line function` to convert tabular data to image samples using:

`[XTrain,model] = deepinsightTab2Img(data,options)`; 

See details by typing `help deepinsightTab2Img` in Matlab console.

To convert test or validation data use `X = deepinsightConv(data,model)`, where `model` is generated from `deepinsightTab2Img` function.

### New updates in this package are:
1) Package is redesigned to simplyfy the usage.
2) A number of projection methods are included: `tsne`,`umap`,`kpca`,`pca` and `lda` (a supervised method).
3) New `blurring` technique is included. This technique populate nearby pixels of characteristic pixels. This technique has shown to improve the classification performance of CNN model significantly. 
4) Conversion of a `d x n` matrix or a `d x n x layers` matrix (3D) is possible. Multi-omics data or multi-layered data can be converted to colored images.
5) For `multi-layered` data (d x n x layers), projection of data using a particular layer (e.g. layer-1) is possible. This will find pixel locations based on layer-1, and the elements of other layers (e.g. layer-2 and layer-3) are mapped to these pixel locations.
6) Continuing from above (4), it is possible to simultaneously use all the layers to find pixel locations. Thereafter, the elements of all the layers are mapped to the common pixel locations.
7) Augmentation of data is possible.


### DeepInsight3D tested on:
OS: Linux Ubuntu 20.04;
Matlab version: 2022a;
GPU A100 (2 parallel);


## Download and Install

1. Download Matlab package DeepInsightTab2Image from the link above. Store it in your working directory and quick check if the codes are working properly:

    ```Matlab
    >> data=rand(5,10);
    >> [XTrain,model] = deepinsightTab2Img(data);
    %following message will be displayed
    NORM-2
    Layer-1 data used for Cart2Pixel
    tSNE with exact algorithm is used
    Distance: euclidean
    Pixels: 224 x 224
    
    >> Xtest = deepinsightConv(rand(5,1),model);
    %following message will be shown
    NORM-2
    ```

The testing is successful if no errors are reported by executing the above two functions

2. Load the example dataset omics.mat (data size is 8.2M):

    ```Matlab
    >>  load omics.mat
    % data = 5062 x 230 x 3 single
    % Labels = 230 x 1 categorical
    ```
The above omics.mat data is a multi-layered data with 5062 dimension, 230 samples and 3 layers: `d=5062; n=230; layers=3`.

3.  Set aside some samples

    ```Matlab
    >>  rng('default');
    >>  inx = randperm(size(data,2));
    >>  inx = inx(1:10);
    >>  dataXts = data(:,r,:); % 5062 x 10 x 3 single
    >>  data(:,r,:) = [];      % 5062 x 220 x 3 single
    >>  LabelsXts = Labels(r); % 10 x 1 categorical
    >>  Labels(r) = [];        % 220 x 1 categorical
    ```
  
4.  Execute Tab2Img function on `data`
    
    ```Matlab
    >>  [XTrain, model] = deepinsightTab2Img(data);
    % This will convert data to images (XTrain) using default parameters
    % XTrain = 224 x 224 x 3 x 220 (4-D uint8) 
    ```
    `model` will defined all the parameters used. Since in the above case options are not changed, default paramters `model.Parm` can be seen.
    
    ```Matlab
    >>  model.Parm
    % struct with fields
    %     Method: 'tsne'
    %       Dist: 'euclidean'
    %     Labels: []
    %  PixelSize: 224
    %       Norm: 2
    %    Augment: 'no'
    % AugSamples: 500 (note: only used when 'Augment' = 'yes')
    % FeatureMap: 1 (i.e. Layer-1 is used for projection and other layers are used for mapping).
    %   Blurring: 'no'
    %   SnowFall: 'no'
    %       Step: 4
    %    MPS_Fix: 1
    ```
    
    `model` also defines normalization parameters (`model.Min` and `model.Max`), pixel locations (`model.xp` and `model.yp`), images sizes and Labels (if      used)
    
5.  Plot the converted sample

    ```Matlab
    >>  imshow(XTrain(:,:,:,1));
    ```
    ![alt text](https://github.com/alok-ai-lab/DeepInsightTab2Image/blob/main/Fig1.png?raw=true)
    
    `DeepInsightTab2Img`- Method: `tsne` with Distance: `euclidean`

6.  Type `help deepinsightTab2Img` for various `options`. Apply blurring technique

    ```Matlab
    >>  [XTrain, model] = deepinsight(data,'Blurring','yes');
    >>  figure; imshow(XTrain(:,:,:,1));
    % nearby pixels of characteristic pixels will be populated
    ```
    ![alt text](https://github.com/alok-ai-lab/DeepInsightTab2Image/blob/main/Fig2.png?raw=true)
    
    `DeepInsightTab2Img`- `Blurring` technique

7.  Convert a validation set or a test set using `model` obtained from (6).

    ```Matlab
    >>  XTest = deepinsightConv(dataXts,model);
    % XTest = 4-D uint8 of size 224 x 224 x 3 x 10 
    ```
    plot XTest images
    ```Matlab
    >>  P = imtile(XTest(:,:,:,1:9)); % these XTest samples belong to different class Labels
    >>  P = rescale(P);
    >>  figure; imshow(P);
    ```
    ![alt text](https://github.com/alok-ai-lab/DeepInsightTab2Image/blob/main/Fig3.png?raw=true)
    
    `deepinsightConv`- plotting Test images
 
8.  Change the `tsne` distance to `cosine` and apply the same procedure

    ```Matlab
    >>  [XTrain, model] = deepinsightTab2Img(data,'Dist','cosine','Blurring','yes'); % distance cosine with Blurring technique
    >>  figure; imshow(XTrain(:,:,:,1)); title('Dist cosine');
    ```
    ![alt text](https://github.com/alok-ai-lab/DeepInsightTab2Image/blob/main/Fig4.png?raw=true)
    
    `DeepInsightTab2Img`- distance: `cosine`

9.  Many options can be changed according to the requirements. Details of options are given below.

    ```Matlab
        'Method': 'tsne' | 'kpca' | 'umap' | 'pca'| 'lda' (supervised method therefore Labels are required)
          'Dist': 'euclidean' (default) | 'seuclidean' | 'cityblock' | 'chebychev' | 'minkowski' | 'mahalanobis' | 
                'cosine' | 'correlation' | 'spearman' | 'hamming' | 
                'jaccard' | function handle.   
                %(Dist variable is applicable only for `tsne` Method option).
        'Labels': Labels (categorical values applicable for Method 'lda' or data augmentation 'Augment','yes')
     'PixelSize': k (default k = 224, will give 224 x 224 image size) | set 'PixelSize',[] to determine pixel frame size automatically 
         'Norm' : 1 | 2
       'Augment': 'no' (default) | yes
    'AugSamples': m (m samples per class, default m is 500)
    'FeatureMap': 0 (all layers used for projection ) | 1 (default) layer-1 projection | 2 (layer-2 projection) | 3 (layer-3 projection)
      'Blurring': 'no' (default) | 'yes'
      'SnowFall': 'no' (default) | 'yes'
          'Step': s (default s=4), s=[1,5]
      'MPS_Fix' : 1 (default) | 0 %(Pixel size will be determined automatically, managed internally)
    ```

10. Apply 'umap' projection method. Note for 'umap', option 'Dist' is not required. Also note, that 'umap' uses Python or R code. Therefore, first install necessary Python/R packages. For Python the following packages are used `numpy`, `sys` and `umap`.

    Moreover, change the default `PixelSize` to 50

    ```Matlab
    >>  [XTrain, model] = deepinsightTab2Img(data,'Method','umap','PixelSize',50);
    % NORM-2
    % Layer-1 data used for Cart2Pixel
    % umap is used
    % Pixels: 50 x 50 
    ```
    
    Plot images of class-1 and class-2
    ```Matlab
    >>  numObservations = [1:8,213:220]; % Labels positions 1:8 belong to class-1 and 213P1=:220 belong to class-2
    >>  P1 = imtile(XTrain(:,:,:,numObservations),'Frames',1:8,'GridSize',[2 4]);
    >>  P2 = imtile(XTrain(:,:,:,numObservations),'Frames',9:16,'GridSize',[2 4]);
    >>  figure; subplot(2,1,1);imshow(P1); title(['class ',num2str(double(Labels(numObservations(1))))]);
    >>  subplot(2,1,2);imshow(P2); title(['class ',num2str(double(Labels(numObservations(9))))]);
    ```
    ![alt text](https://github.com/alok-ai-lab/DeepInsightTab2Image/blob/main/Fig5.png?raw=true)
    
    Uniform Manifold Approximation and Projection (`umap`) with `PizelSize` 50 x 50.
 
11. Using `lda` for projection: since `lda` is a supervised method `Labels` are to be provided

    ```Matlab
    >>  [XTrain, model] = deepinsightTab2Img(data, 'Method', 'lda','Labels',Labels);
    % NORM-2
    % Layer-1 data used for Cart2Pixel
    % lda is used
    % t cluster for LDA 292
    % Pixels: 224 x 224
    ```

    To augment image data apply `Augment` as
    
    ```Matlab
    >>  [XTrain, model] = deepinsightTab2Img(data, 'Method','lda','Augment','yes','Labels',Labels);
    % This will augment around m= 500 samples per class. To change this number apply ...'AugSamples',m ...
    % size of XTrain is 224 x 224 x 3 x 1222
    >>  P = imtile(XTrain(:,:,:,[1,length(Labels)+1));
    >>  figure; imshow(P); title('original and augmented sample');
    ```
    ![alt text](https://github.com/alok-ai-lab/DeepInsightTab2Image/blob/main/Fig6.png?raw=true)
    
    `deepinsightTab2Img`- projection method `lda` with augmentated samples
    
12. Effect of using blurring technique with an illustration

    Generate an artificial image
    ```Matlab
    >>  M = ones(15,15);
    >>  row = [4,9]; col = [4, 7]; % define row and columns for characteristic pixel locations
    >>  M(sub2ind(size(M),row,col)) = 0.4; % define characteristic pixel values
    >>  figure; subplot(2,3,1); imagesc(M); title('original image')
    >>  for step=1:5
    >>      MB = BlurTech(M,row,col,step);
    >>      subplot(2,3,step+1); imagesc(MB); title(['Blurring step ',num2str(step)]);
    >>  end
    ```
    ![alt text](https://github.com/alok-ai-lab/DeepInsightTab2Image/blob/main/Fig7.png?raw=true)
    
    blurring technique with step = 1 .. 5. 

    

## Related materials


# Reference 
* Sharma A*, Lysenko A*, Boroevich K, Tsunoda T*, DeepInsight-3D for precision oncology: an improved anti-cancer drug response prediction from high-dimensional multi-omics data with convolutional neural networks, bioRxiv, 2022 https://doi.org/10.1101/2022.07.14.500140 
* Sharma et al., DeepFeature: feature selection in nonimage data using convolutional neural network, Briefings in Bioinformatics, 22(6), 2021. https://academic.oup.com/bib/article/22/6/bbab297/6343526
* Sharma et al., DeepInsight: a methodology to transform a non-image data to an image for convolution neural network architecture, 9:11399, Scientific Reports, 2019. https://www.nature.com/articles/s41598-019-47765-6
* Castillo-Cara M et al., A Deep Learning Approach Using Blurring Image Techniques for Bluetooth-Based Indoor Localisation, 2022, https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4180099
* Kalkan H et al., Prediction of Alzheimer’s Disease by a Novel Image-Based Representation of Gene Expression, 13(8), Genes, 2022.

### DeepInsight YouTube

A YouTube video about the original DeepInsight method is available [here](https://www.youtube.com/watch?v=411iwaptk24&feature=youtu.be).
A Matlab page on DeepInsight can be viewed from [here](https://www.mathworks.com/company/user_stories/case-studies/riken-develops-a-method-to-apply-cnn-to-non-image-data.html).

### GitHub weblink of DeepInsight (Python and Matlab)
Overall weblink [here](https://alok-ai-lab.github.io/DeepInsight/)


### Winning Kaggle competition by Mark Peng
a) Competition details: Mechanisms of Actions (MoA) Predictions https://www.kaggle.com/competitions/lish-moa

b) *Peng et al., 1st 1st PlaceWinning Solution– Hungry for Gold. Laboratory for Innovation Science at Harvard, Mechanisms of Action (MoA) Prediction Competition 2020.* [here](https://www.kaggle.com/c/lish-moa/discussion/201510)

c) Organizers: MIT and Harvard University (Connectivity Map [here](https://clue.io/))

d) DeepInsight EfficientNet-B3 Noisy Student (PyTorch) [here](https://www.kaggle.com/code/markpeng/deepinsight-efficientnet-b3-noisystudent/notebook)

### Usage of DeepInsight by Subject Area
![alt text](https://github.com/alok-ai-lab/DeepInsight3D/blob/main/Docs_by_Subject.png?raw=true)
#### source: Scopus
