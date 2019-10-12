% Extract available data from annual mean of NEE, PRP, and TEM.
% 2017.4.6
clear;close all;clc

%%  input

NEEmn_fl = '/home/test2/MTE_NEE/NEE_year/ymean/NEEgraFlux_82to11_mean.tif';
PRPmn_fl = '/home/test2/MTE_NEE/MeteoData/Mean/PRP_82to11_mean.tif';
SWRmn_fl = '/home/test2/MTE_NEE/MeteoData/Mean/SWR_82to11_mean.tif';

outpt = '/home/test2/MTE_NEE/NEE_year/ScatterData';

%%  operate

NEEmn = double(imread(NEEmn_fl));
NEEmn(NEEmn==NEEmn(1,1)) = nan;
NEEmn = NEEmn(:);
NEEmn(NEEmn<prctile(NEEmn,2.5)|NEEmn>prctile(NEEmn,97.5)) = nan;

PRPmn = double(imread(PRPmn_fl));
PRPmn(PRPmn==PRPmn(1,1)) = nan;
PRPmn = PRPmn(:);

SWRmn = double(imread(SWRmn_fl));
SWRmn(SWRmn==SWRmn(1,1)) = nan;
SWRmn = SWRmn(:);

idx = find(isnan(NEEmn+PRPmn+SWRmn));

NEEmn(idx) = [];
PRPmn(idx) = [];
SWRmn(idx) = [];

dlmwrite([outpt,'/NEE_ave.txt'],NEEmn);
dlmwrite([outpt,'/PRP_ave.txt'],PRPmn);
dlmwrite([outpt,'/SWR_ave.txt'],SWRmn);

disp('Finish!')

