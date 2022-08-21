# DeepInsightTab2Image
DeepInsight Tab2Image coder: a simple and easy way of converting tabular data to images for convolutional neural networks (CNNs). Improvements are added. One line function for data conversion from tabular to image samples.

One Line code `[XTrain,model] = deepinsightTab2Img(data,options)`; to convert tabular data to images (XTrain). 

See details via typing `help deepinsightTab2Img` in Matlab console.

To convert test or validation data use `X = deepinsightConv(data,model)`, where `model` is generated from `deepinsightTab2Img` function.

New updates in this package are:
1) A number of projection methods are included: `tsne`,`umap`,`kpca`,`pca` and `lda` (a supervised method).
