% 6th Train by JiQiulei test parfor
% Linux
% 2019.9.20
% JiQiulei thrillerlemon@outlook.com
clear;clc


%输入验证次数1-5
i=5;

load('/home/JiQiulei/MTE_JQL_2019/MTE_RunRes/RandomFiveCrossValind.mat');


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
save([out_path, 'RandomCorssValindVar_',random_number]);
mtbuild(TrainSplitX, TrainRegressX, TrainY, AllSplitX, AllRegressX, AllY, binCat, out_path, random_number);
eatstr = ['Completed: ', num2str(i)];
disp(eatstr);
disp('MT have done ~ ~ ~')