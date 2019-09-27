% Test the Var Susceptibility Regress&SplitVar
% Windows 10 1903
% 2019.9.26
% JiQiulei thrillerlemon@outlook.com
clear;clc

outPutPath='E:\OFFICE\MTE_NEE_DATA\RunResult\';
%Test ALLtrainMT ������Ϊmtree
load('E:\OFFICE\MTE_NEE_DATA\RunResult\Run1\MTAllTrain.mat')
%test var
% testVarName=[(string('Frost_day_frequency')),(string('tem')),(string('pre'))];
% testVarName={'elevation','slope'};

%MTE����
allDatapath = 'E:\OFFICE\MTE_NEE_DATA\GRA_Train_NEE_6.xlsx';
%��ȡ���ѱ������ع������Ԥ�����
StandardSplitX = xlsread(allDatapath, 'SplitX');
StandardRegressX = xlsread(allDatapath, 'RegressX');
StandardY = xlsread(allDatapath, 'Y');
%binCat = xlsread(allDatapath, 'binCat');
%46������������������
binCat = zeros(1,46);

%InfoData
[num,txt,raw]=xlsread( allDatapath,'All');
%��ȡ��Ҫ����Ϣ�У����зֱ�Ϊ��վ�㣬latitude,longitude,�꣬�£�NEE��
info_rawData=raw(:,1:6);
%ȡ��All��ǰ���еı�ͷ
infoHead=info_rawData(1,:);
%ȥ�����ݵĵ�һ�б�ͷ
info_rawData(1,:)=[];

%SplitData
[Snum,Stxt,Sraw]=xlsread( allDatapath,'SplitX');
%ȡ��SplitX��ı�ͷ
SHead=Sraw(1,:);

%RegressData
[Rnum,Rtxt,Rraw]=xlsread( allDatapath,'RegressX');
%ȡ��RegressX��ı�ͷ
RHead=Rraw(1,:);


data_bStandard = NaN(1, length(RHead));
data_R2Standard = NaN(1, length(RHead));

data_badd20per = NaN(1, length(RHead));
data_R2add20per = NaN(1, length(RHead));

data_bmin20per = NaN(1, length(RHead));
data_R2min20per = NaN(1, length(RHead));

for i = 1:length(RHead)
    %change Split value
    StestVarIndex=SHead==string(RHead(i));
    add20perSplitX = StandardSplitX;
    min20perSplitX = StandardSplitX;
    add20perSplitX(:, StestVarIndex) = add20perSplitX(:, StestVarIndex)*1.2;
    min20perSplitX(:, StestVarIndex) = min20perSplitX(:, StestVarIndex)*0.2;
    
    %change Regress value
    RtestVarIndex=RHead==string(RHead(i));
    add20perRegressX = StandardRegressX;
    min20perRegressX = StandardRegressX;
    add20perRegressX(:, RtestVarIndex) = add20perRegressX(:, RtestVarIndex)*1.2;
    min20perRegressX(:, RtestVarIndex) = min20perRegressX(:, RtestVarIndex)*0.2;

    %get Standard predict value
    PredictStandardY = MTpredict(mtree, StandardSplitX, StandardRegressX, binCat);
    Y2Standard = [ones(length(PredictStandardY),1),PredictStandardY];
    [bStandard, ~, ~, ~,statsStandard] = regress(StandardY, Y2Standard, 0.01);
    data_bStandard(i) = bStandard(2);
    data_R2Standard(i) = statsStandard(1);    

    %get add20per predict value 
    Predictadd20perY = MTpredict(mtree, add20perSplitX, add20perRegressX, binCat);
    Y2add20per = [ones(length(Predictadd20perY),1),Predictadd20perY];
    [badd20per, ~, ~, ~,statsadd20per] = regress(StandardY, Y2add20per, 0.01);
    data_badd20per(i) = badd20per(2);
    data_R2add20per(i) = statsadd20per(1);  

    %get min20per predict value
    Predictmin20perY = MTpredict(mtree, min20perSplitX, min20perRegressX, binCat);
    Y2min20per = [ones(length(Predictmin20perY),1),Predictmin20perY];
    [bmin20per, ~, ~, ~,statsmin20per] = regress(StandardY, Y2min20per, 0.01);
    data_bmin20per(i) = bmin20per(2);
    data_R2min20per(i) = statsmin20per(1); 

    xlswrite([outPutPath,'Susceptibility_RegressSplitVar_',char(RHead(i)),'.xls'], [infoHead,'PredictStandardY','Predictadd20perY','Predictmin20perY';info_rawData,num2cell(PredictStandardY),num2cell(Predictadd20perY),num2cell(Predictmin20perY)]);

end
save([outPutPath, 'Susceptibility_RegressSplitVar_EnvVar']);
disp('OK')
