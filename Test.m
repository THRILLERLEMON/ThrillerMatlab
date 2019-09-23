close all;clear;clc
%第几次交叉验证 i取1~5
i=1;


%Cross Valind data输入path
path = 'E:\OFFICE\MTE_NEE_DATA\';
% out_path = '/home/JiQiulei/MTE_JQL_2019/MTE_RunRes/';

TestSplitX=xlsread([path,'MTE_CorssValind',num2str(i),'.xlsx'], 'SplitX');
TestRegressX=xlsread([path,'MTE_CorssValind',num2str(i),'.xlsx'], 'RegressX');
TestY=xlsread([path,'MTE_CorssValind',num2str(i),'.xlsx'], 'Y');

TrainSplitX=[];
TrainRegressX=[];
TrainY=[];
for n =1:5
    if n == i
        continue;
    end
    TrainSplitX=[TrainSplitX;xlsread([path,'MTE_CorssValind',num2str(n),'.xlsx'], 'SplitX')];
    TrainRegressX=[TrainRegressX;xlsread([path,'MTE_CorssValind',num2str(n),'.xlsx'], 'RegressX')];
    TrainY=[TrainY;xlsread([path,'MTE_CorssValind',num2str(n),'.xlsx'], 'Y')];
end
disp('aaa')