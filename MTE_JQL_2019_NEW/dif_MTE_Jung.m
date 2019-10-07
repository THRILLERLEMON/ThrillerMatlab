% Caculate the difference between annual mean MTE and ANN, RF, and MARS.
% geotiff
% 2017.5.5
clear;close all;clc

%%  input

MTE_fl = '/home/JiQiulei/MTE_JQL_2019/NEE_Sta/NEEflux_1982-2011_mean.tif';

Jung_pt = '/home/test2/MTE_NEE/JungNEE/Flux/ymean';
Jhd = 'Jung_NEE_FLUX_';
Jft = '_82to11_mean.tif';

outpt = '/home/JiQiulei/MTE_JQL_2019/NEE_Sta';

%%  operate

Rmat = makerefmat('RasterSize',[1752 4320],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

MTE = double(imread(MTE_fl));
MTE(MTE==MTE(1,1)) = nan;

ANN = double(imread([Jung_pt,'/',Jhd,'ANN',Jft]));
ANN(ANN==ANN(1,1)) = nan;
ANN = kron(ANN,ones(6,6));
ANN = ANN(1:1752,:);

RF = double(imread([Jung_pt,'/',Jhd,'RF',Jft]));
RF(RF==RF(1,1)) = nan;
RF = kron(RF,ones(6,6));
RF = RF(1:1752,:);

MARS = double(imread([Jung_pt,'/',Jhd,'MARS',Jft]));
MARS(MARS==MARS(1,1)) = nan;
MARS = kron(MARS,ones(6,6));
MARS = MARS(1:1752,:);

df_ANN = MTE-ANN;
df_RF = MTE-RF;
df_MARS = MTE-MARS;

df_ANN(isnan(df_ANN)) = -9999;
df_RF(isnan(df_RF)) = -9999;
df_MARS(isnan(df_MARS)) = -9999;

geotiffwrite([outpt,'/MTEdf_ANN_82to11.tif'],single(df_ANN),Rmat)
geotiffwrite([outpt,'/MTEdf_RF_82to11.tif'],single(df_RF),Rmat)
geotiffwrite([outpt,'/MTEdf_MARS_82to11.tif'],single(df_MARS),Rmat)

disp('Finish!')
