% Cross Valind 5 times
% Linux
% 2019.9.21
% JiQiulei thrillerlemon@outlook.com
clear;clc


%第几次交叉验证 i取1~5
i=1;


%Cross Valind data输入path
path = '/home/JiQiulei/MTE_JQL_2019/';
out_path = '/home/JiQiulei/MTE_JQL_2019/MTE_RunRes/';
%读入test数据
TestSplitX=xlsread([path,'MTE_CorssValind',num2str(i),'.xlsx'], 'SplitX');
TestRegressX=xlsread([path,'MTE_CorssValind',num2str(i),'.xlsx'], 'RegressX');
TestY=xlsread([path,'MTE_CorssValind',num2str(i),'.xlsx'], 'Y');
%读入训练数据
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

AllSplitX=[TestSplitX;TrainSplitX];
AllRegressX=[TestRegressX;TrainRegressX];
AllY=[TestY;TrainY];
Allnumber = size(AllSplitX, 1);

%46个变量都是连续变量
binCat = zeros(1,46);

save([out_path, 'CorssValindVar_',num2str(i)]);
disp(['save CorssValindVar_',num2str(i)]);
%建立模型树
mtbuild(TrainSplitX, TrainRegressX, TrainY, AllSplitX, AllRegressX, AllY, binCat, out_path, ['CorssValind',num2str(i)]);

disp(['Have Done MTE_CorssValind',num2str(i)]);