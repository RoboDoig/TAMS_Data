function [frames] = videoToFrames(path)
    v = VideoReader(path);
    
    frames = {};
    c = 1;
    while hasFrame(v)
       frames{c} = rgb2gray(readFrame(v)); 
       c = c+1;
    end
end

