function [XTrainNew,YTrainNew] = augmentDeepInsight2(XTrain,YTrain,num)
% augment non-image samples to make it balance for DeepInsight procedure

class = length(unique(double(YTrain)));
classVar = unique(YTrain);
%num=500;

% for j=1:class
%     max_class(j) = sum(double(YTrain)==j);
% end
inx=1:length(double(YTrain));
XTrainNew=[]; YTrainNew=[];
for j=1:class
    %if max_class(j) < num % augment
        [XTrainNewClass,YTrainNewClass] = augmentDeepInsightClass(XTrain,YTrain,num,j,inx); 
        XTrainNew = cat(4,XTrainNew,XTrainNewClass);
        YTrainNew = [YTrainNew;repelem(classVar(j),numel(YTrainNewClass))'];
    %end
end
XTrainNew=cat(4,XTrain,XTrainNew);
YTrainNew=[YTrain;YTrainNew];
