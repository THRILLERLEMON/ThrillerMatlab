% test every MT
% Windows 10 1903
% 2019.9.25
% JiQiulei thrillerlemon@outlook.com
clear;clc

% load
data_b = NaN(1, 5);
data_R2 = NaN(1, 5);
for i = 1:5
    %Test ALLtrainMT
    mtrespath = 'E:\OFFICE\MTE_NEE_DATA\RunResult\Run2\';
    load([mtrespath, 'MTCorssValind',num2str(i),'.mat']);
    load([mtrespath, 'CorssValindVar_', num2str(i), '.mat']);
    PredictTestY = MTpredict(mtree, TestSplitX, TestRegressX, binCat);
    Y2 = [ones(length(PredictTestY),1),PredictTestY];
    [b, ~, ~, ~,stats] = regress(TestY, Y2, 0.01);
    data_b(i) = b(2);
    data_R2(i) = stats(1);
    outresult = [PredictTestY,TestY];
    xlswrite([mtrespath,'MTtestInfo(第一列是PredicTestY第二列是TestY)_',num2str(i),'.xls'], outresult);

end
save(['E:\OFFICE\MTE_NEE_DATA\RunResult\Run2\', 'TestEveryMT_Var']);
disp('OK')
