% 6th Train by JiQiulei test parfor
% Linux
% 2019.9.20
% JiQiulei thrillerlemon@outlook.com
clear;clc

%MTE输入
path = '/home/JiQiulei/MTE_JQL_2019/GRA_Train_NEE_6.xlsx'; %输入文件绝对路径
out_path = '/home/JiQiulei/MTE_JQL_2019/MTE_RunRes/'; %输出文件存放路径，包括训练数据、验证数据及模型

%读取分裂变量、回归变量、预测变量
AllSplitX = xlsread(path, 'SplitX');
AllRegressX = xlsread(path, 'RegressX');
AllY = xlsread(path, 'Y');
%binCat = xlsread(path, 'binCat');
%46个变量都是连续变量
binCat = zeros(1,46);
%一共有多少条数据
Allnumber = size(AllSplitX, 1);
%生成5份进行交叉验证，是一个分组矩阵
indices = crossvalind('Kfold', Allnumber, 5);
save([out_path, 'RandomFiveCrossValind']);
disp('OK Output 5CrossValind ~ ~ ~')