% geotiff
% 2017.5.5
clear;close all;clc

%%  input

NEE_IF = '/home/JiQiulei/MTE_JQL_2019/NEE_Sta/NEEflux_1982-2011_mean.tif';

NEE_noIF = '/home/JiQiulei/MTE_JQL_2019/NEE_Upscale_NoIF_Sum2Year/NoIF_NEEFlux_1982-2011_mean.tif';

outpt = '/home/JiQiulei/MTE_JQL_2019/NEE_Sta';

%%  operate

Rmat = makerefmat('RasterSize',[1752 4320],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

IF = double(imread(NEE_IF));
IF(IF==IF(1,1)) = nan;

noIF = double(imread(NEE_noIF));
noIF(noIF==noIF(1,1)) = nan;

df = IF-noIF;


df(isnan(df)) = -9999;


geotiffwrite([outpt,'/dif_IF_OrNot(82-11FluxYearsMean).tif'],df,Rmat)


disp('Finish!')
