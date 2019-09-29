% Combine 10 forests
% Windows 10 1903
% 2019.9.29
% JiQiulei thrillerlemon@outlook.com
clear;clc

matPath='E:\OFFICE\MTE_NEE_DATA\RunResult\Run9\';
allMTrees=[];
for i = 1:10
    load([matPath,'Forest',num2str(i),'.mat']);
    if i==1
        allMTrees=forest;
        continue;
    end
    allMTrees = [allMTrees,forest];
end
save([matPath,'Forest1000.mat'],'allMTrees');
disp('OK');