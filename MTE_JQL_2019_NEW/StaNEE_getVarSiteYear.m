% Get the Var Susceptibility Info yearly
% Windows 10 1903
% 2019.10.2
% JiQiulei thrillerlemon@outlook.com
clear;clc


outPutPath='E:\OFFICE\MTE_NEE_DATA\RunResult\StaNEE_Frost_SR_space\';

%MTE����
allDatapath = 'E:\OFFICE\MTE_NEE_DATA\GRA_Train_NEE_6.xlsx';
%��ȡ���ѱ������ع������Ԥ�����
StandardRegressX = xlsread(allDatapath, 'RegressX');

%InfoData
[num,txt,raw]=xlsread( allDatapath,'All');
%ȡ��All��ǰ���еı�ͷ
infoHead=raw(1,:);
%ȥ�����ݵĵ�һ�б�ͷ
raw(1,:)=[];

%��ȡ������������site year
ForstIndex=infoHead==string('Frost_day_frequency');
SRIndex=infoHead==string('MM_short_radiation');
siteIndex=infoHead==string('վ��');
nianIndex=infoHead==string('��');

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


