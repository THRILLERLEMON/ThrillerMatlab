% 6th Train by JiQiulei
% Linux
% 2019.9.20
% JiQiulei thrillerlemon@outlook.com
clear;clc

%MTE����
path = '/home/JiQiulei/MTE_JQL_2019/GRA_Train_NEE_6.xlsx'; %�����ļ�����·��
out_path = '/home/JiQiulei/MTE_JQL_2019/MTE_RunRes/'; %����ļ����·��������ѵ�����ݡ���֤���ݼ�ģ��

%��ȡ���ѱ������ع������Ԥ�����
AllSplitX = xlsread(path, 'SplitX');
AllRegressX = xlsread(path, 'RegressX');
AllY = xlsread(path, 'Y');
%binCat = xlsread(path, 'binCat');
%46������������������
binCat = zeros(1,46);

%һ���ж���������
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