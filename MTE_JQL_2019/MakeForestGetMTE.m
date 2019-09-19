% begin from a MT to a forest and get MTE
% Linux
% 2019.9.20
% JiQiulei thrillerlemon@outlook.com
clear;clc
% load
bestMTpath = 'D:\OneDrive\SharedFile\MTE_NEE\JiQiulei20180928\result\MT1.mat';
load(bestMTpath);
mtEnsemble(mtree, TrainSplitX, TrainRegressX, TrainY, AllSplitX, AllRegressX, AllY, binCat, out_path,90, 40, 200, 25)
disp('OK make Forest');
% load
forestpath = 'D:\OneDrive\SharedFile\MTE_NEE\JiQiulei20180928\result\Forest1.mat';
load(forestpath);
R2Info = Found_Best_Ensemble_From_Forest(TrainSplitX, TrainRegressX,TrainY,TestSplitX,TestRegressX,TestY,AllSplitX, AllRegressX,AllY,binCat,forest)
save([out_path, 'MTE_R2Info.mat'],'R2Info');
disp('OK get best MTE info');