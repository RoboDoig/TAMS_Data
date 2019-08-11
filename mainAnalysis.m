% clear all; close all; clc;
close all;
% %% get data and generate metrics
% dataFile = 'TSeries-08062019-1859-083.mat';
% load(dataFile);
% generateActivityMetrics;

frontPawXFilt = bandpassFilter(dataSet.frontPawX, 1, 20, 200, 4); frontPawXFilt(1:200) = 0;
frontPawYFilt = bandpassFilter(dataSet.frontPawY, 1, 20, 200, 4); frontPawYFilt(1:200) = 0;
hindPawXFilt  = bandpassFilter(dataSet.hindPawX, 1, 20, 200, 4); hindPawXFilt(1:200) = 0;
hindPawYFilt  = bandpassFilter(dataSet.hindPawY, 1, 20, 200, 4); hindPawYFilt(1:200) = 0;
filteredMotion = [frontPawXFilt; frontPawYFilt; hindPawXFilt; hindPawYFilt];
motionPhase = nan(size(filteredMotion, 1), size(filteredMotion, 2));
instFrq = nan(size(filteredMotion, 1), size(filteredMotion, 2));

% getting phase info, instantaneous frequency
for i = 1:size(filteredMotion, 1)
    envelope = movstd(filteredMotion(i,:), 200); phase = angle(hilbert(filteredMotion(i,:))); phase(envelope<10) = 0;
    motionPhase(i,:) = phase;
    
    iHz = instfreq(filteredMotion(i,:),200,'Method','hilbert');
    iHz(envelope<10) = 0;
    instFrq(i,:) = sgolayfilt(iHz, 2, 201);
end

% correlation check
allRFront = nan(size(zscored,1),1);
allRBack = nan(size(zscored,1),1);
for i = 1:size(zscored,1)
   [rFront, ~] = xcorr(zscored(i,:), instFrq(1,:), 'coeff');
   [rBack, ~] = xcorr(zscored(i,:), instFrq(3,:), 'coeff');
   allRFront(i,1) = max(rFront);
   allRBack(i,1) = max(rBack);
end

figure; hold on;
[sortFront, iFront] = sort(allRFront);
[sortBack, iBack] = sort(allRBack);
plot(sortFront, 'm')
plot(sortBack, 'b')

figure; 
plot(allRFront-allRBack, 'k');

figure; hold on;
testZ = zscored; testZ(testZ<0.5) = NaN;
scatter(nanmean(testZ'), allRFront, 'm')
scatter(nanmean(testZ'), allRBack, 'b')

% example correlated cells
% front 
[m, I] = max(allRFront);
figure; hold on; set(gcf,'Position',[100 100 700 300]);
plot(dataSet.time, zscored(I,:)+0.5,'k');
plot(dataSet.time, -instFrq(1,:), 'm');
plot(dataSet.time, -instFrq(3,:), 'b');
xlim([0 max(dataSet.time)])

% back
[m, I] = max(allRBack);
figure; hold on; set(gcf,'Position',[100 100 700 300]);
plot(dataSet.time, zscored(I,:)+0.5,'k');
plot(dataSet.time, -instFrq(1,:), 'm');
plot(dataSet.time, -instFrq(3,:), 'b');
xlim([0 max(dataSet.time)])

% diff
[m, I] = max(allRFront-allRBack);
figure; hold on; set(gcf,'Position',[100 100 700 300]);
plot(dataSet.time, zscored(I,:)+0.5,'k');
plot(dataSet.time, -instFrq(1,:), 'm');
plot(dataSet.time, -instFrq(3,:), 'b');
xlim([0 max(dataSet.time)])

% heatmaps most correlated
mostIdx = iFront(501:580);
figure; subplot(3,1,1:2)
imagesc(dataSet.time, 1:size(mostIdx,1), zscored(mostIdx, :)); colormap('hot'); caxis([-1 20]);
subplot(3,1,3); hold on;
plot(dataSet.time, -instFrq(1,:), 'm');
plot(dataSet.time, -instFrq(3,:), 'b');
xlim([0 max(dataSet.time)])

%% video example
% vidTimeRange = 20:50;
% vidTimeRange = 795:825;
% vidFileName = {'run.avi', 'run_cells.avi'};
% rois = [6, 8, 15, 16];
% centers = {[421, 383], [347, 181], [69, 263], [380, 198]};
% exampleVideo




