% 6th Train by JiQiulei IF is a regress var
% Linux
% 2019.9.27
% JiQiulei thrillerlemon@outlook.com
clear;clc
warning('off')

%MTE输入
path = '/home/JiQiulei/MTE_JQL_2019_IFregress/IFregress_GRA_Train_NEE_6 .xlsx'; %输入文件绝对路径
out_path = '/home/JiQiulei/MTE_JQL_2019_IFregress/MTE_RunRes/'; %输出文件存放路径，包括训练数据、验证数据及模型

%读取分裂变量、回归变量、预测变量
AllSplitX = xlsread(path, 'SplitX');
AllRegressX = xlsread(path, 'RegressX');
AllY = xlsread(path, 'Y');
%binCat = xlsread(path, 'binCat');
%46个变量都是连续变量
binCat = zeros(1,45);

%一共有多少条数据
Allnumber = size(AllSplitX, 1);

TrainSplitX = AllSplitX;
TrainRegressX = AllRegressX;
TrainY = AllY;
TestSplitX = AllSplitX;
TestRegressX = AllRegressX;
TestY = AllY;

disp('Save Training EnvVar');
save([out_path, 'Training_EnvVar']);

mtbuild(TrainSplitX, TrainRegressX, TrainY, AllSplitX, AllRegressX, AllY, binCat, out_path, 'AllTrain');

disp('MT have done ~ ~ ~')