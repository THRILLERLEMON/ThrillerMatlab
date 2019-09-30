% Test the Var Susceptibility SplitVarOnly————MTE
% Windows 10 1903
% 2019.9.30
% JiQiulei thrillerlemon@outlook.com
clear;clc

outPutPath='E:\OFFICE\MTE_NEE_DATA\RunResult\';
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

%InfoData
[num,txt,raw]=xlsread( allDatapath,'All');
%读取需要的信息列，六列分别为【站点，latitude,longitude,年，月，NEE】
info_rawData=raw(:,1:6);
%取出All表前六列的表头
infoHead=info_rawData(1,:);
%去掉数据的第一行表头
info_rawData(1,:)=[];

%SplitData
[Snum,Stxt,Sraw]=xlsread( allDatapath,'SplitX');
%取出SplitX表的表头
SHead=Sraw(1,:);


data_bStandard = NaN(1, length(SHead));
data_R2Standard = NaN(1, length(SHead));

data_badd20per = NaN(1, length(SHead));
data_R2add20per = NaN(1, length(SHead));

data_bmin20per = NaN(1, length(SHead));
data_R2min20per = NaN(1, length(SHead));

for i = 1:length(SHead)
    testVarIndex=SHead==string(SHead(i));
    add20perSplitX = StandardSplitX;
    min20perSplitX = StandardSplitX;

    add20perSplitX(:, testVarIndex) = add20perSplitX(:, testVarIndex)*1.2;
    min20perSplitX(:, testVarIndex) = min20perSplitX(:, testVarIndex)*0.8;

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
    mteadd20perY = mtepredict(bestMTE, add20perSplitX, StandardRegressX, binCat);
    for a = 1:size(mteadd20perY, 1)
        Predictadd20perY(a, 1) = mean(mteadd20perY(a,:));
    end 
    Y2add20per = [ones(length(Predictadd20perY),1),Predictadd20perY];
    [badd20per, ~, ~, ~,statsadd20per] = regress(StandardY, Y2add20per, 0.01);
    data_badd20per(i) = badd20per(2);
    data_R2add20per(i) = statsadd20per(1);  

    %get min20per predict value
    mtemin20perY = mtepredict(bestMTE, min20perSplitX, StandardRegressX, binCat);
    for m = 1:size(mtemin20perY, 1)
        Predictmin20perY(m, 1) = mean(mtemin20perY(m,:));
    end 
    Y2min20per = [ones(length(Predictmin20perY),1),Predictmin20perY];
    [bmin20per, ~, ~, ~,statsmin20per] = regress(StandardY, Y2min20per, 0.01);
    data_bmin20per(i) = bmin20per(2);
    data_R2min20per(i) = statsmin20per(1); 

    xlswrite([outPutPath,'MTE_Susceptibility_SplitVarOnly_',char(SHead(i)),'.xls'], [infoHead,'PredictStandardY','Predictadd20perY','Predictmin20perY';info_rawData,num2cell(PredictStandardY),num2cell(Predictadd20perY),num2cell(Predictmin20perY)]);

end
save([outPutPath, 'MTE_Susceptibility_SplitVarOnly_EnvVar']);
disp('OK')
