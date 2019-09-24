% test every MT
% Linux
% 2019.9.23
% JiQiulei thrillerlemon@outlook.com
clear;clc

% load
data_b = NaN(1, 5);
data_R2 = NaN(1, 5);
for i = 1:5
    %Test ALLtrainMT
    mtrespath = '/home/JiQiulei/MTE_JQL_2019/MTE_RunRes/';
    load([mtrespath, 'MTCorssValind',num2str(i),'.mat']);
    load([mtrespath, 'CorssValindVar_', num2str(i), '.mat']);
    PredictTestY = MTpredict(mtree, TestSplitX, TestRegressX, binCat);
    Y2 = [ones(length(PredictTestY),1),PredictTestY];
    [b, ~, ~, ~,stats] = regress(TestY, Y2, 0.01);
    data_b(i) = b(2);
    data_R2(i) = stats(1);
    outresult = [PredictTestY,TestY];
    disResult = ['result_',num2str(i),'第一列是PredicTestY，第二列是TestY'];
    disp(disResult);
    disp(outresult);
    eatstr = ['Completed :', num2str(i*100/5), '%'];
    disp(eatstr);
end
save([out_path, 'TestEveryMT_Var']);
disp('OK')
