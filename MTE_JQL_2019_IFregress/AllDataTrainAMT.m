% 6th Train by JiQiulei IF is a regress var
% Linux
% 2019.9.27
% JiQiulei thrillerlemon@outlook.com
clear;clc
warning('off')

%MTE����
path = '/home/JiQiulei/MTE_JQL_2019_IFregress/IFregress_GRA_Train_NEE_6 .xlsx'; %�����ļ�����·��
out_path = '/home/JiQiulei/MTE_JQL_2019_IFregress/MTE_RunRes/'; %����ļ����·��������ѵ�����ݡ���֤���ݼ�ģ��

%��ȡ���ѱ������ع������Ԥ�����
AllSplitX = xlsread(path, 'SplitX');
AllRegressX = xlsread(path, 'RegressX');
AllY = xlsread(path, 'Y');
%binCat = xlsread(path, 'binCat');
%46������������������
binCat = zeros(1,45);

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