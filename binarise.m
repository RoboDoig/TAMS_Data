function [binarised] = binarise(input, threshold)
    binarised = zeros(1,length(input));
    binarised(input>=threshold) = 1;
end

