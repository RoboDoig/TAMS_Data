%% video reader sandbox
clear all; close all; clc;

folder = 'C:\Users\imaging\TAMS_Data\BehaviorVids';
file = 'TamsMcD190806_3-labeled.avi';

v = VideoReader(fullfile(folder, file));

