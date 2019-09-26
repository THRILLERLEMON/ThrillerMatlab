% Run 5MT without Intensive_frac
% Linux
% 2019.9.26
% JiQiulei thrillerlemon@outlook.com
clear;clc
warning('off')

%������֤����1-5
i=1;

%MTE����
path = '/home/JiQiulei/MTE_JQL_2019/GRA_Train_NEE_6_NoIF.xlsx'; %�����ļ�����·��
out_path = '/home/JiQiulei/MTE_JQL_2019/MTE_RunRes/'; %����ļ����·��������ѵ�����ݡ���֤���ݼ�ģ��

%��ȡ���ѱ������ع������Ԥ�����
AllSplitX = xlsread(path, 'SplitX');
AllRegressX = xlsread(path, 'RegressX');
AllY = xlsread(path, 'Y');
%binCat = xlsread(path, 'binCat');
%46������������������,����һ����Ϊ45
binCat = zeros(1,45);
%һ���ж���������
Allnumber = size(AllSplitX, 1);


%load indices
load('/home/JiQiulei/MTE_JQL_2019/MTE_RunRes/indices.mat');


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
random_number = ['NoIF_RandomCorssValind',num2str(i)];
disp(['save',' test', num2str(i)]);
save([out_path, 'NoIF_RandomCorssValindVar_',num2str(i)]);
mtbuild(TrainSplitX, TrainRegressX, TrainY, AllSplitX, AllRegressX, AllY, binCat, out_path, random_number);
eatstr = ['Completed: ', num2str(i)];
disp(eatstr);
disp('MT have done ~ ~ ~')