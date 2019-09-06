clear;clc

%MTE输入
path = '/home/JiQiulei/NEE/GRA_Train_NEE_5.xlsx'; %输入文件绝对路径
out_path = '/home/JiQiulei/NEE/JiQiulei20180928/result/'; %输出文件存放路径，包括训练数据、验证数据及模型

%读取分裂变量、回归变量、预测变量
AllSplitX = xlsread(path, 'SplitX');
AllRegressX = xlsread(path, 'RegressX');
AllY = xlsread(path, 'Y');
%binCat = xlsread(path, 'binCat');
binCat = zeros(1,37);

%AllSplitX = AllSplitX(1:200,:);
%AllRegressX = AllRegressX(1:200,:);
%AllY = AllY(1:200,:);


Allnumber = size(AllSplitX, 1);
indices = crossvalind('Kfold', Allnumber, 5);
for i = 1:5
    test = (indices == i);
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
end
disp('MT have done ~ ~ ~')