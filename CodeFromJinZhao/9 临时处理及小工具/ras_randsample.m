% 栅格数据随机取点，结果导出至TXT文件
% geotiff

clear;close all;clc

%%  user

ras_file = 'E:\生态系统-植被\延河黄绵土模拟数据\YH_gridclass.tif';  % 栅格数据文件
valid = [0, 300];  % 栅格数据有效范围
smpnum = 100;  % 随机选点个数
outtxt = 'E:\生态系统-植被\延河黄绵土模拟数据\随机选点结果.txt';

%%  calculate

rasfl = double(imread(ras_file));
rasfl(rasfl < valid(1) | rasfl > valid(2)) = nan;

rasvd = rasfl(~isnan(rasfl));
idxsm = randperm(length(rasfl(~isnan(rasfl))), smpnum);

dlmwrite(outtxt, rasvd(idxsm))

disp('OK!')