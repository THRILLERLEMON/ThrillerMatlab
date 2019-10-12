% Output Best MTE
% Linux
% 2019.9.20
% JiQiulei thrillerlemon@outlook.com
clear;clc

bestNumberOfTree=20;
% load
forestpath = 'D:\OneDrive\SharedFile\MTE_NEE\JiQiulei20180928\result\Forest1.mat';
load(forestpath);

bestMTE = TF(forest, bestNumberOfTree);
save('/home/JiQiulei/MTE_JQL_2019/MTE_RunRes/bestMTE.mat','bestMTE');
disp('OK output best MTE');