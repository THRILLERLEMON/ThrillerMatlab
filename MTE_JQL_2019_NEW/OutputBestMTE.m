% Output Best MTE
% Windows 10 1903
% 2019.9.30
% JiQiulei thrillerlemon@outlook.com
clear;clc

bestNumberOfTree=16;

% load
forestpath = 'E:\OFFICE\MTE_NEE_DATA\RunResult\Run10\Forest1000.mat';
load(forestpath);

bestMTE = TF(forest, bestNumberOfTree);
save('E:\OFFICE\MTE_NEE_DATA\RunResult\bestMTE.mat','bestMTE');
disp('OK output best MTE');