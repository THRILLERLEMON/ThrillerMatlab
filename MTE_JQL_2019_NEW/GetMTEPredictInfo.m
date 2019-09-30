% Find MTE info to find Best MTE
% Linux
% 2019.9.29
% JiQiulei thrillerlemon@outlook.com
clear;clc

warning('off')

% load
oneMTvar = '/home/JiQiulei/MTE_JQL_2019/MTE_RunRes/Training_EnvVar.mat';
load(oneMTvar);

% load Forest var name is allMTrees
forestpath='/home/JiQiulei/MTE_JQL_2019/MTE_RunRes/';
load([forestpath,'Forest1000.mat']);

R2 = NaN(2, 100);
for i = 1:100
    R2(1, i) = i;
    ensemble = TF(allMTrees, i);
    PredictAllY = mtepredict(ensemble, AllSplitX, AllRegressX, binCat);
    [~,stats] = test(PredictAllY, AllY, 2);
    R2(2, i) = stats(1);
    eststr = ['Completing :', num2str(i), ' Trees Ensemble'];
    disp(eststr);
end

save([forestpath, 'MTE_R2Info.mat'],'R2');
save([forestpath, 'MTEINFO_EnvVar']);
disp('Save All Script EnvVar');
    