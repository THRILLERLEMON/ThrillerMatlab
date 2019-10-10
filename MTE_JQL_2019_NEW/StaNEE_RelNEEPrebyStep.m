% The coefficient of partial correlation between NEE with PRP and TEM.
% geotiff
% 2017.5.13
tic;clear;close all;clc

%%  Input

NEEpt = 'C:\Users\thril\Desktop\NEEfluxsum_82to11_mean.tif';
PRPpt = 'E:\OFFICE\MTE_NEE_DATA\RunResult\Sta_NEE\PRP_82to11_mean.tif';
outpt = 'C:\Users\thril\Desktop\';  % Outpath

%%  pm

NEE = double(imread(NEEpt)); 
NEE(NEE==-9999) = nan;
PRP = double(imread(PRPpt)); 
PRP(PRP==-9999) = nan;

PRPBounds=[100,2000];
PRPStep=10;
PRP_rg=PRPBounds(1):PRPStep:PRPBounds(2);

resData=[];

for ip = 1:length(PRP_rg)-1
    idx = PRP>=PRP_rg(ip) & PRP<PRP_rg(ip+1) ;
    NEEMean=nanmean(NEE(idx));
    NEEStd=nanstd(NEE(idx));
    resData=[resData;PRP_rg(ip),NEEMean,NEEStd];
end



xlswrite([outpt,'RelNEE_PRPbyStep.xls'], resData);



disp('OK!')