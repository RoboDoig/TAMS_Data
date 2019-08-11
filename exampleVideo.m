v = VideoReader(dataSet.video);
w = VideoWriter(vidFileName{1}); w.FrameRate = 200;

idxMin = find(dataSet.time>=vidTimeRange(1),1); idxMax = find(dataSet.time>=vidTimeRange(end),1);
range = idxMin:idxMax;
[S, I] = sort(max(zscored'), 'descend');

%% behavior
c = 1;
open(w);
for i = idxMin:idxMax
   frameIndex = find(dataSet.frameTimes>=i, 1);
   frame = read(v, frameIndex);
   
   % camera frame
   figure(100); set(gcf,'Position',[100 100 600 900], 'color', 'k'); subplot(5,1,1:2);
   imagesc(frame); set(gca, 'YTickLabel', [], 'XTickLabel', [], 'YTick', [], 'XTick', []);
   
   % heatmap
   subplot(5,1,4:5);
   map = zscored(I,range); map(:,c:end) = -100;
   imagesc(dataSet.time(range), 1:size(dff,1), map); colormap('hot'); caxis([-1 20]);
   
   % behavior trace
   subplot(5,1,3);
   trace = filteredMotion(1, range); trace(c:end) = NaN;
   plot(dataSet.time(range), trace, 'w'); 
   trace = motionPhase(1, range); trace(c:end) = NaN; hold on;
   plot(dataSet.time(range), (trace*20) - 100, 'r'); hold off;
   xlim([min(dataSet.time(range)) max(dataSet.time(range))]); ylim([-200, 200]); set(gca, 'Color', 'k', 'YTickLabel', [], 'YTick', []);
   
   % write to video
   F = getframe(gcf);
   writeVideo(w, F);
   
   c = c + 1;
end
close(w);

%% cells
w = VideoWriter(vidFileName{2}); w.FrameRate = 200;
imagingFrames = dir([dataSet.folder, '/*.tif']);
imagingFrames = {imagingFrames.name};
lastImgIdx = 1;

% indicator graphic
template = zeros(512,512);
mark = uint16(rgb2gray(insertShape(template,'circle',[centers{1}(2) centers{1}(1), 10;
    centers{2}(2) centers{2}(1), 10;
    centers{3}(2) centers{3}(1), 10;
    centers{4}(2) centers{4}(1), 10],'LineWidth',2)))*500;
num = uint16(rgb2gray(insertText(template,[centers{1}(2)+6, centers{1}(1)-20;
    centers{2}(2)+6, centers{2}(1)-20;
    centers{3}(2)+6, centers{3}(1)-20;
    centers{4}(2)+6, centers{4}(1)-20],{'1','2','3','4'},'TextColor','w','BoxColor','black','FontSize',20)))*500;

c = 1;
open(w)
for i = idxMin:idxMax
    tic
    
    imgIdx = dataSet.fImageIndex(i);
    if imgIdx ~= lastImgIdx
        img = imread(fullfile(dataSet.folder, imagingFrames{imgIdx}));
        lastImgIdx = imgIdx;
    end
    
    figure(101);
    set(gcf,'Position',[100 100 600 900], 'color', 'k');
    
    % 2p image
    subplot(4,1,1:2);
    imagesc(img+mark+num); colormap('gray'); caxis([0 500]);
    set(gca, 'YTickLabel', [], 'XTickLabel', [], 'YTick', [], 'XTick', []);
    
    % 2p trace
    subplot(4,1,3:4); hold off;
    for j = 1:4
        trace = zscored(rois(j), range)-((j-1)*6); trace(c:end) = NaN;
        plot(dataSet.time(range), trace, 'w'); hold on;      
    end
    set(gca, 'Color', 'k', 'YTickLabel', [], 'YTick', []);
    xlim([min(dataSet.time(range)) max(dataSet.time(range))]); ylim([-22 7]);
    
   % write to video
   F = getframe(gcf);
   writeVideo(w, F);
    
    c = c + 1;
    disp(toc);
end

close(w);




