% 6th Train by JiQiulei test parfor
% Linux
% 2019.9.20
% JiQiulei thrillerlemon@outlook.com
clear;clc

%MTE输入
path = '/home/JiQiulei/MTE_JQL_2019_parfor/GRA_Train_NEE_6.xlsx'; %输入文件绝对路径
out_path = '/home/JiQiulei/MTE_JQL_2019_parfor/MTE_RunRes/'; %输出文件存放路径，包括训练数据、验证数据及模型

%读取分裂变量、回归变量、预测变量
AllSplitX = xlsread(path, 'SplitX');
AllRegressX = xlsread(path, 'RegressX');
AllY = xlsread(path, 'Y');
%binCat = xlsread(path, 'binCat');
%46个变量都是连续变量
binCat = zeros(1,46);

%AllSplitX = AllSplitX(1:200,:);
%AllRegressX = AllRegressX(1:200,:);
%AllY = AllY(1:200,:);

%一共有多少条数据
Allnumber = size(AllSplitX, 1);
%生成5份进行交叉验证，是一个分组矩阵
indices = crossvalind('Kfold', Allnumber, 5);
parpool(5)
parfor i = 1:5
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
    random_number = num2str(i);
    disp(['save',' test', num2str(i)]);
    parsave([out_path, 'Test_',random_number],Allnumber,AllRegressX,AllSplitX,AllY,binCat,i,indices,out_path,path,random_number,test,TestRegressX,TestSplitX,TestY,train,TrainRegressX,TrainSplitX,TrainY);
    mtbuild(TrainSplitX, TrainRegressX, TrainY, AllSplitX, AllRegressX, AllY, binCat, out_path, random_number);
    eatstr = ['Completed: ', num2str(i)];
    disp(eatstr);
end
disp('MT have done ~ ~ ~')