% 6th Train by JiQiulei test parfor
% Linux
% 2019.9.20
% JiQiulei thrillerlemon@outlook.com
clear;clc

%MTE����
path = '/home/JiQiulei/MTE_JQL_2019_parfor/GRA_Train_NEE_6.xlsx'; %�����ļ�����·��
out_path = '/home/JiQiulei/MTE_JQL_2019_parfor/MTE_RunRes/'; %����ļ����·��������ѵ�����ݡ���֤���ݼ�ģ��

%��ȡ���ѱ������ع������Ԥ�����
AllSplitX = xlsread(path, 'SplitX');
AllRegressX = xlsread(path, 'RegressX');
AllY = xlsread(path, 'Y');
%binCat = xlsread(path, 'binCat');
%46������������������
binCat = zeros(1,46);

%AllSplitX = AllSplitX(1:200,:);
%AllRegressX = AllRegressX(1:200,:);
%AllY = AllY(1:200,:);

%һ���ж���������
Allnumber = size(AllSplitX, 1);
%����5�ݽ��н�����֤����һ���������
indices = crossvalind('Kfold', Allnumber, 5);
parpool(5)
parfor i = 1:5
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
    parsave([out_path, 'Test_',random_number],Allnumber,AllRegressX,AllSplitX,AllY,binCat,i,indices,out_path,path,random_number,test,TestRegressX,TestSplitX,TestY,train,TrainRegressX,TrainSplitX,TrainY);
    mtbuild(TrainSplitX, TrainRegressX, TrainY, AllSplitX, AllRegressX, AllY, binCat, out_path, random_number);
    eatstr = ['Completed: ', num2str(i)];
    disp(eatstr);
end
disp('MT have done ~ ~ ~')