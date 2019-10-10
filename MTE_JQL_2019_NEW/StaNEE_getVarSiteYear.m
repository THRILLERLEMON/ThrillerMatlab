% Get the Var Susceptibility Info yearly
% Windows 10 1903
% 2019.10.2
% JiQiulei thrillerlemon@outlook.com
clear;clc


outPutPath='E:\OFFICE\MTE_NEE_DATA\RunResult\StaNEE_Frost_SR_space\';

%MTE输入
allDatapath = 'E:\OFFICE\MTE_NEE_DATA\GRA_Train_NEE_6.xlsx';
%读取分裂变量、回归变量、预测变量
StandardRegressX = xlsread(allDatapath, 'RegressX');

%InfoData
[num,txt,raw]=xlsread( allDatapath,'All');
%取出All表前六列的表头
infoHead=raw(1,:);
%去掉数据的第一行表头
raw(1,:)=[];

%提取这两个参数的site year
ForstIndex=infoHead==string('Frost_day_frequency');
SRIndex=infoHead==string('MM_short_radiation');
siteIndex=infoHead==string('站点');
nianIndex=infoHead==string('年');

Forst=cell2mat(raw(:, ForstIndex));
SR=cell2mat(raw(:, SRIndex));
site=string(raw(:, siteIndex));
nian=string(raw(:, nianIndex));
siteyearTemp=[site,nian];
uqSiteYear=unique(siteyearTemp,'rows');

SiteYearData=[];
for nSY = 1:size(uqSiteYear,1)
    pSite=uqSiteYear(nSY,1);
    pYear=uqSiteYear(nSY,2);
    SYindex = (site==pSite) & (nian == pYear);
    ForstSYTemp=sum(Forst(SYindex,:));
    SRSYTemp=sum(SR(SYindex,:));
    SiteYearData=[SiteYearData;[pSite,pYear,ForstSYTemp,SRSYTemp]];
end

varSusInfo=[[string('Site'),string('Year'),string('Frost_day_frequency'),string('MM_short_radiation')];SiteYearData];


xlswrite([outPutPath,'ForstandSR_SiteYear.xls'], cellstr(varSusInfo));
disp('ok!')


