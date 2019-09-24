% begin from a MT to a forest and get MTE
% Linux
% 2019.9.23
% JiQiulei thrillerlemon@outlook.com
clear;clc
% load
warning('off')

oneMTpath = '/home/JiQiulei/MTE_JQL_2019/MTE_RunRes/MTAllTrain.mat';
load(oneMTpath);
oneMTvar = '/home/JiQiulei/MTE_JQL_2019/MTE_RunRes/Training_EnvVar.mat';
load(oneMTvar);
mtEnsemble(mtree, TrainSplitX, TrainRegressX, TrainY, AllSplitX, AllRegressX, AllY, binCat, out_path,90, 40, 200, 25);
disp('OK make Forest');

% load
forestpath = '/home/JiQiulei/MTE_JQL_2019/MTE_RunRes/Forest1.mat';
load(forestpath);
R2Info = Found_Best_Ensemble_From_Forest(TrainSplitX, TrainRegressX,TrainY,TestSplitX,TestRegressX,TestY,AllSplitX, AllRegressX,AllY,binCat,forest);

save([out_path, 'MTE_R2Info.mat'],'R2Info');
disp('OK get best MTE info');
save([out_path, 'GetMTE_EnvVar']);
disp('Save All Script EnvVar');