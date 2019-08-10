%% S1 analysis preprocessing
clear all; close all; clc;
disp('loading raw data...');
folders = {'TSeries-08062019-1859-083', 'TSeries-08062019-1859-084'};
offsets = {1:37871, 37872:40000}; % suite2p data for 2 experiments is saved as single concatenated file, choose which data points
behavior = {'TamsMcD190806_3.mat', 'TamsMcD190806_4.mat'};
fold = 1; % select dataset

% fluorescence data from suite2p
dataset = load(fullfile(folders{fold}, 'suite2p/plane0/Fall.mat'));
% Bruker frame attributes
[nFrames, tSeries] = parseFrameVals(xml2struct(fullfile(folders{fold}, [folders{fold}, '.xml'])));
% voltage recording
voltage = load(fullfile(folders{fold}, 'voltage.mat')); 
voltage.CameraFrame = binarise(downsample(voltage.CameraFrame, 10), 0.5);
voltage.Timems = downsample(voltage.Timems', 10);
voltage.VisStim = binarise(downsample(voltage.VisStim', 10), 0.5);
voltage.WheelSpeed = downsample(voltage.WheelSpeed', 10);
% behavior
behaviorData = load(behavior{fold});

%% get good cells
disp('extracting suite2p data')
cellIdx = find(dataset.iscell(:, 1) == 1);
fCell = dataset.F(cellIdx, offsets{fold});
neuCell = dataset.Fneu(cellIdx, offsets{fold});
spksCell = dataset.spks(cellIdx, offsets{fold});
f = fCell - (neuCell * 0.7);
% f = fCell;

%% time align fluorescence data into higher hz voltage sampling
disp('time align fluorescence')
fAligned = nan(size(f,1), length(voltage.Timems));
spksAligned = nan(size(f,1), length(voltage.Timems));
for t = 1:length(tSeries)
   tIdxMin = find(voltage.Timems>=tSeries(t),1);
   fAligned(:,tIdxMin) = f(:,t);
   spksAligned(:,tIdxMin) = spksCell(:,t);
end
fAligned(:, end) = 0; fInterp = fillmissing(fAligned', 'linear')';
spksAligned(:, end) = 0; spksInterp = fillmissing(spksAligned', 'linear')';


%% time align behavior data to frame counter
disp('time align deep-lab-cut')
frameTrigger = abs(diff(voltage.CameraFrame));
[pks, locs] = findpeaks(frameTrigger);
frontPawX = nan(1,length(voltage.Timems));
frontPawX(locs) = behaviorData.front_paw_x; frontPawX(1:locs(1)) = frontPawX(locs(1)); frontPawX(end) = frontPawX(locs(end)); frontPawX = fillmissing(frontPawX, 'linear');
frontPawY = nan(1,length(voltage.Timems));
frontPawY(locs) = behaviorData.front_paw_y; frontPawY(1:locs(1)) = frontPawY(locs(1)); frontPawY(end) = frontPawY(locs(end)); frontPawY = fillmissing(frontPawY, 'linear');
hindPawX = nan(1,length(voltage.Timems));
hindPawX(locs) = behaviorData.hind_paw_x; hindPawX(1:locs(1)) = hindPawX(locs(1)); hindPawX(end) = hindPawX(locs(end)); hindPawX = fillmissing(hindPawX, 'linear');
hindPawY = nan(1,length(voltage.Timems));
hindPawY(locs) = behaviorData.hind_paw_y; hindPawY(1:locs(1)) = hindPawY(locs(1)); hindPawY(end) = hindPawY(locs(end)); hindPawY = fillmissing(hindPawY, 'linear');


%% optional downsample for speed, consolidate data
disp('consolidating, saving')
dataSet = struct();
dataSet.time        = downsample(voltage.Timems/1000, 5);
dataSet.cameraFrame = downsample(voltage.CameraFrame, 5);
dataSet.visStim     = downsample(voltage.VisStim, 5);
dataSet.wheelSpeed  = downsample(voltage.WheelSpeed, 5);
dataSet.frontPawX   = downsample(frontPawX, 5);
dataSet.frontPawY   = downsample(frontPawY, 5);
dataSet.hindPawX    = downsample(hindPawX, 5);
dataSet.hindPawY    = downsample(hindPawY, 5);
dataSet.f           = downsample(fInterp', 5)';
dataSet.spks        = downsample(spksInterp', 5)';
dataSet.frameTimes  = locs/5;

save([folders{fold}, '.mat'], 'dataSet', '-v7.3')