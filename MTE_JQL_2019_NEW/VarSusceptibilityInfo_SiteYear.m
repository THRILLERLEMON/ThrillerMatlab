% Get the Var Susceptibility Info yearly
% Windows 10 1903
% 2019.10.2
% JiQiulei thrillerlemon@outlook.com
clear;clc

% varPath='E:\OFFICE\MTE_NEE_DATA\RunResult\Run13\addmin20perChangeSplitandRegress\';
varPath='E:\OFFICE\MTE_NEE_DATA\RunResult\Run13\addmin20perOnlyChangeSplit\';

%取目录下所有excel文件的文件名(.xls或.xlsx)
getfilename=ls([varPath,'*.xls*']); 
filename = cellstr(getfilename);
num_of_files = length(filename); 
varSusInfo={('Name'),('add20%ChangeMean'),('add20%Stdeva'),('min20%ChangeMean'),('min20%Stdeva')};
for i=1:num_of_files 
    file_address=strcat(varPath,filename(i));
    %将cell转化为string
    file_address=file_address{1};
    [num,txt,raw]=xlsread( file_address,'Sheet1');
    infoHead=raw(1,:);
    bgData=ones(size(raw,1)-1,1);
    nianIndex=infoHead==string('年');
    NEEIndex=infoHead==string('NEE');
    StandardYIndex=infoHead==string('PredictStandardY');
    add20perYIndex=infoHead==string('Predictadd20perY');
    min20perYIndex=infoHead==string('Predictmin20perY');
    tempRawData=[bgData,num];
    nian=tempRawData(:, nianIndex);
    NEE=tempRawData(:, NEEIndex);
    StaY=tempRawData(:, StandardYIndex);
    add20perY=tempRawData(:, add20perYIndex);
    min20perY=tempRawData(:, min20perYIndex);
    addChangePer=((add20perY-StaY)./StaY)*100;
    minChangePer=((min20perY-StaY)./StaY)*100;

    for y=1998:2006
        varYear=[char(filename(i)),num2str(y)];
        thisyear = (nian == y);
        addChangePer(thisyear, :)
        addchangeMean=mean(abs(addChangePer(thisyear, :)));
        addchangeStd=std(abs(addChangePer(thisyear, :)));
        minchangeMean=mean(abs(minChangePer(thisyear, :)));
        minchangeStd=std(abs(minChangePer(thisyear, :)));
        tempInfo=[{varYear},addchangeMean,addchangeStd,minchangeMean,minchangeStd];
        varSusInfo=[varSusInfo;tempInfo];
    end

end

xlswrite(['E:\OFFICE\MTE_NEE_DATA\RunResult\','MTE_SusceptibilityInfo_OnlySplitVar.xls'], varSusInfo);
disp('ok!')

