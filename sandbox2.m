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
    prct = thisF(thisF <= prctile(thisF, 25));
    f0 = median(prct);
    if f0 < 1 % fudge for silent cells
        f0 = 1; 
    end   
    dff(i,:) = (thisF - f0) / f0;   
    normalised(i,:) = (dff(i,:) - min(dff(i,:))) / (max(dff(i,:)) - min(dff(i,:)));
    zscored(i, :) = zscore(thisF);
    meanActivity(i) = mean(dff(i,:));
    
    allF0(i) = f0;
    
%     close all;
%     figure; subplot(3,1,1); hold on;
%     plot(dataSet.time, thisF, 'k')
%     plot([0 max(dataSet.time)], [f0, f0], 'r--')
%     subplot(3,1,2);
%     plot(dataSet.time, dff(i,:),'k');
%     subplot(3,1,3);
%     plot(dataSet.time, zscored(i,:),'k');
end

figure; subplot(3,1,1:2);
imagesc(dataSet.time, 1:size(dff,1), zscored); colormap('hot'); caxis([-1 20]);
subplot(3,1,3);
plot(dataSet.time, dataSet.wheelSpeed, 'k'); xlim([0 max(dataSet.time)])

range = 4000:16000;
figure; subplot(3,1,1:2);
imagesc(dataSet.time(range), 1:size(dff,1), zscored(:, range)); colormap('hot'); caxis([-1 20]);
subplot(3,1,3);
plot(dataSet.time(range), dataSet.frontPawX(range), 'k'); xlim([min(dataSet.time(range)) max(dataSet.time(range))])

%% finding video frame for point
% v = VideoReader(dataSet.video);
% 
% time = 0;
% index = find(dataSet.time>=time, 1);
% frameIndex = find(dataSet.frameTimes>=index, 1);
% frame = read(v, frameIndex);
% 
% figure;
% imagesc(frame)

%% create movie of data range
v = VideoReader(dataSet.video);
timeRange = 20:30; %time range in seconds
idxMin = find(dataSet.time>=timeRange(1),1); idxMax = find(dataSet.time>=timeRange(end),1);

for i = idxMin:idxMax
   frameIndex =  find(dataSet.frameTimes>=i, 1);
   frame = read(v, frameIndex);
end