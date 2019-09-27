% test every random MT
% Windows 10 1903
% 2019.9.25
% JiQiulei thrillerlemon@outlook.com
clear;clc


[num,txt,raw]=xlsread( 'E:\OFFICE\MTE_NEE_DATA\GRA_Train_NEE_6.xlsx','All');

%读取需要的信息列，六列分别为【站点，latitude,longitude,年，月，NEE】
rawData=raw(:,1:6);
dataHead=rawData(1,:);
%去掉数据的第一行表头
rawData(1,:)=[];

% load
data_btrain = NaN(1, 5);
data_R2train = NaN(1, 5);
data_btest = NaN(1, 5);
data_R2test = NaN(1, 5);

for i = 1:5
    %Test ALLtrainMT
    mtrespath = 'E:\OFFICE\MTE_NEE_DATA\RunResult\Run6\';
    %需要修改
    load([mtrespath, 'MTNoIF_RandomCorssValind',num2str(i),'.mat']);
    load([mtrespath, 'NoIF_RandomCorssValindVar_', num2str(i), '.mat']);
    %get predict value
    PredictTrainY = MTpredict(mtree, TrainSplitX, TrainRegressX, binCat);
    PredictTestY = MTpredict(mtree, TestSplitX, TestRegressX, binCat);

    Y2train = [ones(length(PredictTrainY),1),PredictTrainY];
    Y2test = [ones(length(PredictTestY),1),PredictTestY];

    [btrain, ~, ~, ~,statstrain] = regress(TrainY, Y2train, 0.01);
    [btest, ~, ~, ~,statstest] = regress(TestY, Y2test, 0.01);

    data_btrain(i) = btrain(2);
    data_R2train(i) = statstrain(1);

    data_btest(i) = btest(2);
    data_R2test(i) = statstest(1);

    TrainSMinfo = rawData(train, :);
    TestSMinfo = rawData(test, :);
    
    xlswrite([mtrespath,'NoIF_RandomMTtrainInfo_',num2str(i),'.xls'], [dataHead,'PredictTrainY';TrainSMinfo,num2cell(PredictTrainY)]);
    xlswrite([mtrespath,'NoIF_RandomMTtestInfo_',num2str(i),'.xls'], [dataHead,'PredictTestY';TestSMinfo,num2cell(PredictTestY)]);

end
save([mtrespath, 'TestEveryNoIF_RandomMTEnv_Var']);
disp('OK')
