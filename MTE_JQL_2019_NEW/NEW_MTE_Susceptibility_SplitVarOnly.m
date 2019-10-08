% Test the Var Susceptibility SplitVarOnly————MTE
% Windows 10 1903
% 2019.10.8
% JiQiulei thrillerlemon@outlook.com
clear;clc

outPutPath='E:\OFFICE\MTE_NEE_DATA\RunResult\Susceptibility_SplitVarOnly\';
%Test ALLtrainMT 变量名为bestMTE
load('E:\OFFICE\MTE_NEE_DATA\RunResult\Run12\bestMTE.mat')

%MTE输入
allDatapath = 'E:\OFFICE\MTE_NEE_DATA\GRA_Train_NEE_6.xlsx';
%读取分裂变量、回归变量、预测变量
StandardSplitX = xlsread(allDatapath, 'SplitX');
StandardRegressX = xlsread(allDatapath, 'RegressX');
StandardY = xlsread(allDatapath, 'Y');
%binCat = xlsread(allDatapath, 'binCat');
%46个变量都是连续变量
binCat = zeros(1,46);

% load('E:\OFFICE\MTE_NEE_DATA\RunResult\Run4\indices.mat');
% %拿出一份测试,第3组比较好
% outBoxIndex = (indices == 3);

% StandardSplitX = StandardSplitX(outBoxIndex, :);
% StandardRegressX = StandardRegressX(outBoxIndex, :);
% StandardY = StandardY(outBoxIndex, :);


%InfoData
[num,txt,raw]=xlsread( allDatapath,'All');
%读取需要的信息列，六列分别为【站点，latitude,longitude,年，月，NEE】
info_rawData=raw(:,1:6);
%取出All表前六列的表头
infoHead=info_rawData(1,:);
%去掉数据的第一行表头
info_rawData(1,:)=[];
% info_rawData=info_rawData(outBoxIndex, :);

%SplitData
[Snum,Stxt,Sraw]=xlsread( allDatapath,'SplitX');
%取出SplitX表的表头
SHead=Sraw(1,:);


data_bStandard = NaN(1, length(SHead));
data_R2Standard = NaN(1, length(SHead));

data_bRandomTest = NaN(1, length(SHead));
data_R2RandomTest = NaN(1, length(SHead));


for i = 1:length(SHead)
    testVarIndex=SHead==string(SHead(i));
    randomSplitX = StandardSplitX;
    %随机序列
    dataRandIndex=randperm(size(StandardSplitX,1));
    dataTemp=randomSplitX(:, testVarIndex);
    randomSplitX(:, testVarIndex) = dataTemp(dataRandIndex,:);

    %get Standard predict value
    mteY= mtepredict(bestMTE, StandardSplitX, StandardRegressX, binCat);
    for o = 1:size(mteY, 1)
        PredictStandardY(o, 1) = mean(mteY(o,:));
    end 
    Y2Standard = [ones(length(PredictStandardY),1),PredictStandardY];
    [bStandard, ~, ~, ~,statsStandard] = regress(StandardY, Y2Standard, 0.01);
    data_bStandard(i) = bStandard(2);
    data_R2Standard(i) = statsStandard(1);    

    %get add20per predict value 
    mterandomTestY = mtepredict(bestMTE, randomSplitX, StandardRegressX, binCat);
    for a = 1:size(mterandomTestY, 1)
        PredictrandomTestY(a, 1) = mean(mterandomTestY(a,:));
    end 
    Y2randomTest = [ones(length(PredictrandomTestY),1),PredictrandomTestY];
    [brandomTest, ~, ~, ~,statsrandomTest] = regress(StandardY, Y2randomTest, 0.01);
    data_bRandomTest(i) = brandomTest(2);
    data_R2RandomTest(i) = statsrandomTest(1);  

    xlswrite([outPutPath,'MTE_Susceptibility_SplitVarOnly_',char(SHead(i)),'.xls'], [infoHead,'PredictStandardY','PredictRandomTestY';info_rawData,num2cell(PredictStandardY),num2cell(PredictrandomTestY)]);
end
cha=data_R2Standard-data_R2RandomTest;
chaPer=cha./data_R2Standard;
outputInfo=[string('Var'),SHead;string('R2Standard'),data_R2Standard;string('R2RandomTest'),data_R2RandomTest;string('ChangePer'),chaPer];
xlswrite([outPutPath,'All_MTE_Susceptibility_SplitVarOnly.xls'], cellstr(outputInfo));
save([outPutPath, 'MTE_Susceptibility_SplitVarOnly_EnvVar']);
disp('OK')
