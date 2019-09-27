% 6th Train by JiQiulei IF is a regress var
% Linux
% 2019.9.27
% JiQiulei thrillerlemon@outlook.com
clear;clc
warning('off')


%输入验证次数1-5
i=4;

%MTE输入
path = '/home/JiQiulei/MTE_JQL_2019_IFregress/IFregress_GRA_Train_NEE_6 .xlsx'; %输入文件绝对路径
out_path = '/home/JiQiulei/MTE_JQL_2019_IFregress/MTE_RunRes/'; %输出文件存放路径，包括训练数据、验证数据及模型

%读取分裂变量、回归变量、预测变量
AllSplitX = xlsread(path, 'SplitX');
AllRegressX = xlsread(path, 'RegressX');
AllY = xlsread(path, 'Y');
%binCat = xlsread(path, 'binCat');
%46个变量都是连续变量,少了一个，为45
binCat = zeros(1,45);
%一共有多少条数据
Allnumber = size(AllSplitX, 1);
%IF变成了回归变量，所以少了一个，从新赋值

%load indices
load('/home/JiQiulei/MTE_JQL_2019_IFregress/MTE_RunRes/indices.mat');


%拿出一份测试
test = (indices == i);
%其他的训练的4份
train = ~ test;
TrainSplitX = AllSplitX(train, :);
TrainRegressX = AllRegressX(train, :);
TrainY = AllY(train, :);
TestSplitX = AllSplitX(test, :);
TestRegressX = AllRegressX(test, :);
TestY = AllY(test, :);
random_number = ['RandomCorssValind',num2str(i)];
disp(['save',' test', num2str(i)]);
save([out_path, 'RandomCorssValindVar_',num2str(i)]);
mtbuild(TrainSplitX, TrainRegressX, TrainY, AllSplitX, AllRegressX, AllY, binCat, out_path, random_number);
eatstr = ['Completed: ', num2str(i)];
disp(eatstr);
disp('MT have done ~ ~ ~')