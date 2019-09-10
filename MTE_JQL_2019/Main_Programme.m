clear;clc

%MTE����
path = 'D:\\OneDrive\\SharedFile\\MTE_NEE\\GRA_Train_NEE_5.xlsx'; %�����ļ�����·��
out_path = 'C:\\Users\\thril\\Desktop\\MTEtest'; %����ļ����·��������ѵ�����ݡ���֤���ݼ�ģ��

%��ȡ���ѱ������ع������Ԥ�����
AllSplitX = xlsread(path, 'SplitX');
AllRegressX = xlsread(path, 'RegressX');
AllY = xlsread(path, 'Y');
%binCat = xlsread(path, 'binCat');
binCat = zeros(1,37);

%AllSplitX = AllSplitX(1:200,:);
%AllRegressX = AllRegressX(1:200,:);
%AllY = AllY(1:200,:);

%һ���ж���������
Allnumber = size(AllSplitX, 1);
%����5�ݽ��н�����֤����һ���������
indices = crossvalind('Kfold', Allnumber, 5);
for i = 1:5
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
end
disp('MT have done ~ ~ ~')