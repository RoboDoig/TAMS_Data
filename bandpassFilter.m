function [filtered] = bandpassFilter(input, fLow, fHigh, fs, order)
    [b, a] = butter(order, [fLow, fHigh]/(fs/2), 'bandpass');
    filtered = filter(b,a,input);
end

