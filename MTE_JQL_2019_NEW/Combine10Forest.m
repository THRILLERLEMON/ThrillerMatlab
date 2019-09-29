% Combine 10 forests
% Linux
% 2019.9.29
% JiQiulei thrillerlemon@outlook.com
clear;clc

matPath='/home/JiQiulei/MTE_JQL_2019/MTE_RunRes/';
allMTrees=[];
for i = 1:10
    load([matPath,'Forest',num2str(i),'.mat']);
    if i==1
        allMTrees=forest;
        continue;
    end
    allMTrees = CombineF(allMTrees,forest);
end
save([matPath,'Forest1000.mat'],'allMTrees');
disp('OK');