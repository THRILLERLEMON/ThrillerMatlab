% Run 5MT without Intensive_frac
% Linux
% 2019.9.26
% JiQiulei thrillerlemon@outlook.com
clear;clc
warning('off')

%输入验证次数1-5
i=1;

%MTE输入
path = '/home/JiQiulei/MTE_JQL_2019/GRA_Train_NEE_6_NoIF.xlsx'; %输入文件绝对路径
out_path = '/home/JiQiulei/MTE_JQL_2019/MTE_RunRes/'; %输出文件存放路径，包括训练数据、验证数据及模型

%读取分裂变量、回归变量、预测变量
AllSplitX = xlsread(path, 'SplitX');
AllRegressX = xlsread(path, 'RegressX');
AllY = xlsread(path, 'Y');
%binCat = xlsread(path, 'binCat');
%46个变量都是连续变量,少了一个，为45
binCat = zeros(1,45);
%一共有多少条数据
Allnumber = size(AllSplitX, 1);


%load indices
load('/home/JiQiulei/MTE_JQL_2019/MTE_RunRes/indices.mat');


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
random_number = ['NoIF_RandomCorssValind',num2str(i)];
disp(['save',' test', num2str(i)]);
save([out_path, 'NoIF_RandomCorssValindVar_',num2str(i)]);
mtbuild(TrainSplitX, TrainRegressX, TrainY, AllSplitX, AllRegressX, AllY, binCat, out_path, random_number);
eatstr = ['Completed: ', num2str(i)];
disp(eatstr);
disp('MT have done ~ ~ ~')