% 6th Train by JiQiulei test parfor
% Linux
% 2019.9.20
% JiQiulei thrillerlemon@outlook.com
clear;clc


%������֤����1-5
i=2;

load('/home/JiQiulei/MTE_JQL_2019_parfor/MTE_RunRes/FiveCrossValind.mat');


%�ó�һ�ݲ���
test = (indices == i);
%������ѵ����4��
train = ~ test;
TrainSplitX = AllSplitX(train, :);
TrainRegressX = AllRegressX(train, :);
TrainY = AllY(train, :);
TestSplitX = AllSplitX(test, :);
TestRegressX = AllRegressX(test, :);
TestY = AllY(test, :);
random_number = num2str(i);
disp(['save',' test', num2str(i)]);
save([out_path, 'Test_',random_number]);
mtbuild(TrainSplitX, TrainRegressX, TrainY, AllSplitX, AllRegressX, AllY, binCat, out_path, random_number);
eatstr = ['Completed: ', num2str(i)];
disp(eatstr);
disp('MT have done ~ ~ ~')