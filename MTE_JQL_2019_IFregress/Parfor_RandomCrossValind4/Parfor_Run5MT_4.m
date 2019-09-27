% 6th Train by JiQiulei IF is a regress var
% Linux
% 2019.9.27
% JiQiulei thrillerlemon@outlook.com
clear;clc
warning('off')


%������֤����1-5
i=4;

%MTE����
path = '/home/JiQiulei/MTE_JQL_2019_IFregress/IFregress_GRA_Train_NEE_6 .xlsx'; %�����ļ�����·��
out_path = '/home/JiQiulei/MTE_JQL_2019_IFregress/MTE_RunRes/'; %����ļ����·��������ѵ�����ݡ���֤���ݼ�ģ��

%��ȡ���ѱ������ع������Ԥ�����
AllSplitX = xlsread(path, 'SplitX');
AllRegressX = xlsread(path, 'RegressX');
AllY = xlsread(path, 'Y');
%binCat = xlsread(path, 'binCat');
%46������������������,����һ����Ϊ45
binCat = zeros(1,45);
%һ���ж���������
Allnumber = size(AllSplitX, 1);
%IF����˻ع��������������һ�������¸�ֵ

%load indices
load('/home/JiQiulei/MTE_JQL_2019_IFregress/MTE_RunRes/indices.mat');


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
random_number = ['RandomCorssValind',num2str(i)];
disp(['save',' test', num2str(i)]);
save([out_path, 'RandomCorssValindVar_',num2str(i)]);
mtbuild(TrainSplitX, TrainRegressX, TrainY, AllSplitX, AllRegressX, AllY, binCat, out_path, random_number);
eatstr = ['Completed: ', num2str(i)];
disp(eatstr);
disp('MT have done ~ ~ ~')