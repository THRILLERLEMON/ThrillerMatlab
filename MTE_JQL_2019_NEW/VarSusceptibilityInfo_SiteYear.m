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
varSusInfo={('Name_SiteYear'),('add20%ChangeMean'),('add20%Stdeva'),('min20%ChangeMean'),('min20%Stdeva')};
for i=1:num_of_files 
    file_address=strcat(varPath,filename(i));
    %将cell转化为string
    file_address=file_address{1};
    [num,txt,raw]=xlsread( file_address,'Sheet1');
    infoHead=raw(1,:);
    bgData=ones(size(raw,1)-1,1);
    siteIndex=infoHead==string('站点');
    nianIndex=infoHead==string('年');
    StandardYIndex=infoHead==string('PredictStandardY');
    add20perYIndex=infoHead==string('Predictadd20perY');
    min20perYIndex=infoHead==string('Predictmin20perY');

    tempRawData=[bgData,num];
    site=string(raw(:, siteIndex));
    site(1)=[];
    nian=tempRawData(:, nianIndex);
    StaY=tempRawData(:, StandardYIndex);
    add20perY=tempRawData(:, add20perYIndex);
    min20perY=tempRawData(:, min20perYIndex);

    sitenames=unique(site);
    SiteYearData=[];
    for nSite = 1:length(sitenames)
        for y=1998:2006
            pSite=sitenames(nSite);
            thisSiteYear = ((nian == y)&(site==pSite));
            thisSY_StaY=sum(StaY(thisSiteYear,:));
            thisSY_add20perY=sum(add20perY(thisSiteYear,:));
            thisSY_min20perY=sum(min20perY(thisSiteYear,:));
            if thisSY_StaY==0 && thisSY_add20perY==0 && thisSY_min20perY==0
                continue
            end
            siteYearTemp=[thisSY_StaY,thisSY_add20perY,thisSY_min20perY];
            SiteYearData=[SiteYearData;siteYearTemp];
        end
    end
    allSY_StaY=SiteYearData(:,1);
    allSY_add20perY=SiteYearData(:,2);
    allSY_min20perY=SiteYearData(:,3);
    addChangePer=((allSY_add20perY-allSY_StaY)./allSY_StaY)*100;
    minChangePer=((allSY_min20perY-allSY_StaY)./allSY_StaY)*100;
    addchangeMean=mean(abs(addChangePer));
    addchangeStd=std(abs(addChangePer));
    minchangeMean=mean(abs(minChangePer));
    minchangeStd=std(abs(minChangePer));
    tempInfo=[filename(i),addchangeMean,addchangeStd,minchangeMean,minchangeStd];
    varSusInfo=[varSusInfo;tempInfo];
end

xlswrite(['E:\OFFICE\MTE_NEE_DATA\RunResult\','MTE_SusceptibilityInfo_OnlySplitVar_SiteYearChange.xls'], varSusInfo);
disp('ok!')


