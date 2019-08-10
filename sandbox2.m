%% postprocess
clear all; close all; clc;

load('TSeries-08062019-1859-083.mat');

%% dFF
dff = nan(size(dataSet.f, 1), size(dataSet.f, 2));
normalised = nan(size(dataSet.f, 1), size(dataSet.f, 2));
zscored = nan(size(dataSet.f, 1), size(dataSet.f, 2));

meanActivity = nan(1,size(dataSet.f, 1));
allF0 = nan(1,size(dataSet.f, 1));
for i = 1:size(dff,1)
    thisF = dataSet.f(i, :);
    prct = thisF(thisF <= prctile(thisF, 40));
    f0 = median(prct)+(std(prct));
    if f0 < 1 % fudge for silent cells
        f0 = 1; 
    end   
    dff(i,:) = (thisF - f0) / f0;   
    normalised(i,:) = (dff(i,:) - min(dff(i,:))) / (max(dff(i,:)) - min(dff(i,:)));
    zscored(i, :) = zscore(thisF);
    meanActivity(i) = mean(dff(i,:));
    
    allF0(i) = f0;
    
%     close all;
%     figure; subplot(2,1,1); hold on;
%     plot(dataSet.time, thisF, 'k')
%     plot([0 max(dataSet.time)], [f0, f0], 'r--')
%     subplot(2,1,2);
%     plot(dataSet.time, dff(i,:),'k');
end

figure; subplot(3,1,1:2);
imagesc(dataSet.time, 1:size(dff,1), zscored); colormap('hot')
subplot(3,1,3);
plot(dataSet.time, dataSet.wheelSpeed, 'k'); xlim([0 max(dataSet.time)])