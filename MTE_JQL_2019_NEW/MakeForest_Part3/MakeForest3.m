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
mtEnsemble(mtree, TrainSplitX, TrainRegressX, TrainY, AllSplitX, AllRegressX, AllY, binCat, out_path,90, 40, 100, 25);
disp('OK make Forest');

save([out_path, 'MakeForest_EnvVar']);
disp('Save All Script EnvVar');