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

% figure; subplot(3,1,1:2);
% imagesc(dataSet.time, 1:size(dff,1), zscored); colormap('hot'); caxis([-1 20]);
% subplot(3,1,3);
% plot(dataSet.time, dataSet.wheelSpeed, 'k'); xlim([0 max(dataSet.time)])
% 
% range = 4000:16000;
% figure; subplot(3,1,1:2);
% imagesc(dataSet.time(range), 1:size(dff,1), zscored(:, range)); colormap('hot'); caxis([-1 20]);
% subplot(3,1,3);
% plot(dataSet.time(range), dataSet.frontPawX(range), 'k'); xlim([min(dataSet.time(range)) max(dataSet.time(range))])

%% create movie of data range
v = VideoReader(dataSet.video);
w = VideoWriter('test3.avi'); w.FrameRate = 200;
timeRange = 570:620; %time range in seconds
idxMin = find(dataSet.time>=timeRange(1),1); idxMax = find(dataSet.time>=timeRange(end),1);
range = idxMin:idxMax;

c = 1;
open(w);
for i = idxMin:idxMax
   tic
   disp(i);
   frameIndex =  find(dataSet.frameTimes>=i, 1);
   frame = read(v, frameIndex);
   
   % camera frame
   figure(1); set(gcf,'Position',[100 100 600 900], 'color', 'k');
   subplot(5,1,1:2);
   imagesc(frame); set(gca, 'YTickLabel', [], 'XTickLabel', [], 'YTick', [], 'XTick', []);
   % heatmap
   subplot(5,1,4:5);
   map = zscored(:,range); map(:,c:end) = -100;
   imagesc(dataSet.time(range), 1:size(dff,1), map); colormap('hot'); caxis([-1 20]);
   % behavior trace
   subplot(5,1,3);
   trace = dataSet.frontPawX(range); trace(c:end) = NaN;
   plot(dataSet.time(range), trace, 'w'); xlim([min(dataSet.time(range)) max(dataSet.time(range))]); ylim([600, 1000])
   set(gca, 'Color', 'k')
   F = getframe(gcf);
   writeVideo(w, F);
   
   c = c+1;
   disp(toc);
end
close(w);