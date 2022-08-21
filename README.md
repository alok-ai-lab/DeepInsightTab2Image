# DeepInsightTab2Image
DeepInsight Tab2Image coder: a simple and easy way of converting tabular data to images for convolutional neural networks (CNNs). Improvements are added. One line function for data conversion from tabular to image samples.

One Line code `[XTrain,model] = deepinsightTab2Img(data,options)`; to convert tabular data to images (XTrain). 

See details via typing `help deepinsightTab2Img` in Matlab console.

To convert test or validation data use `X = deepinsightConv(data,model)`, where `model` is generated from `deepinsightTab2Img` function.

New updates in this package are:
1) A number of projection methods are included: `tsne`,`umap`,`kpca`,`pca` and `lda` (a supervised method).
2) New `blurring` method included which populate pixels with values nearby characteristic pixels. This improves the classification performance of CNN model significantly on many cases. 
3) Conversion of a `d x n` matrix or a `d x n x layers` matrix (3D) is possible. Multi-omics data or multi-layered data can be converted to colored images.
4) For `multi-layered` data (d x n x layers), projection of data using a particular layer (e.g. layer-1) is possible. This will find pixel locations based on layer-1, and the elements of other layers (e.g. layer-2 and layer-3) are mapped to these pixel locations.
5) Continuing from above (4), it is possible to simultaneously use all the layers to find pixel locations. Thereafter, the elements of all the layers are mapped to the common pixel locations.
6) Augmentation of data is possible.
