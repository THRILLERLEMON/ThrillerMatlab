% Test the Var Susceptibility Regress&SplitVar
% Windows 10 1903
% 2019.10.08
% JiQiulei thrillerlemon@outlook.com
clear;clc

outPutPath='E:\OFFICE\MTE_NEE_DATA\RunResult\Susceptibility_RegressSplitVar\';
%Test ALLtrainMT ������ΪbestMTE
load('E:\OFFICE\MTE_NEE_DATA\RunResult\Run12\bestMTE.mat')


%MTE����
allDatapath = 'E:\OFFICE\MTE_NEE_DATA\GRA_Train_NEE_6.xlsx';
%��ȡ���ѱ������ع������Ԥ�����
StandardSplitX = xlsread(allDatapath, 'SplitX');
StandardRegressX = xlsread(allDatapath, 'RegressX');
StandardY = xlsread(allDatapath, 'Y');
%binCat = xlsread(allDatapath, 'binCat');
%46������������������
binCat = zeros(1,46);

% load('E:\OFFICE\MTE_NEE_DATA\RunResult\Run4\indices.mat');
% %�ó�һ�ݲ���,��3��ȽϺ�
% outBoxIndex = (indices == 3);

% StandardSplitX = StandardSplitX(outBoxIndex, :);
% StandardRegressX = StandardRegressX(outBoxIndex, :);
% StandardY = StandardY(outBoxIndex, :);

%InfoData
[num,txt,raw]=xlsread( allDatapath,'All');
%��ȡ��Ҫ����Ϣ�У����зֱ�Ϊ��վ�㣬latitude,longitude,�꣬�£�NEE��
info_rawData=raw(:,1:6);
%ȡ��All��ǰ���еı�ͷ
infoHead=info_rawData(1,:);
%ȥ�����ݵĵ�һ�б�ͷ
info_rawData(1,:)=[];
% info_rawData=info_rawData(outBoxIndex, :);

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

data_bRandomTest = NaN(1, length(RHead));
data_R2RandomTest = NaN(1, length(RHead));


for i = 1:length(RHead)
    %�������
    dataRandIndex=randperm(size(StandardSplitX,1));

    %change Split value
    StestVarIndex=SHead==string(RHead(i));
    randomSplitX = StandardSplitX;
    SplitXTemp=randomSplitX(:, StestVarIndex);
    randomSplitX(:, StestVarIndex) = SplitXTemp(dataRandIndex,:);
    
    %change Regress value
    RtestVarIndex=RHead==string(RHead(i));
    randomRegressX = StandardRegressX;
    RegressXTemp=randomRegressX(:, RtestVarIndex);
    randomRegressX(:, RtestVarIndex)=RegressXTemp(dataRandIndex,:);

    %get Standard predict value
    mteY = mtepredict(bestMTE, StandardSplitX, StandardRegressX, binCat);
    for o = 1:size(mteY, 1)
        PredictStandardY(o, 1) = mean(mteY(o,:));
    end 
    Y2Standard = [ones(length(PredictStandardY),1),PredictStandardY];
    [bStandard, ~, ~, ~,statsStandard] = regress(StandardY, Y2Standard, 0.01);
    data_bStandard(i) = bStandard(2);
    data_R2Standard(i) = statsStandard(1);    

    %get add20per predict value 
    mterandomTest = mtepredict(bestMTE, randomSplitX, randomRegressX, binCat);
    for a = 1:size(mterandomTest, 1)
        PredictrandomTestY(a, 1) = mean(mterandomTest(a,:));
    end 
    Y2randomTest = [ones(length(PredictrandomTestY),1),PredictrandomTestY];
    [brandomTest, ~, ~, ~,statsrandomTest] = regress(StandardY, Y2randomTest, 0.01);
    data_bRandomTest(i) = brandomTest(2);
    data_R2RandomTest(i) = statsrandomTest(1);  

    xlswrite([outPutPath,'MTE_Susceptibility_RegressSplitVar_',char(RHead(i)),'.xls'], [infoHead,'PredictStandardY','PredictRandomTestY';info_rawData,num2cell(PredictStandardY),num2cell(PredictrandomTestY)]);

end

cha=data_R2Standard-data_R2RandomTest;
chaPer=cha./data_R2Standard;
outputInfo=[string('Var'),SHead;string('R2Standard'),data_R2Standard;string('R2RandomTest'),data_R2RandomTest;string('ChangePer'),chaPer];
xlswrite([outPutPath,'All_MTE_Susceptibility_RegressSplitVar.xls'], cellstr(outputInfo));

save([outPutPath, 'MTE_Susceptibility_RegressSplitVar_EnvVar']);
disp('OK')
