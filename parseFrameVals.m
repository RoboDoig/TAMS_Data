function [nFrames, tSeries] = parseFrameVals(frameStruct)
    attr = frameStruct.PVScan.Sequence;
    nFrames = length(attr.Frame);
    tSeries = nan(1, nFrames);
    for i = 1:nFrames
       tSeries(i) = str2double(attr.Frame{i}.Attributes.relativeTime)*1000.0; 
    end
end

