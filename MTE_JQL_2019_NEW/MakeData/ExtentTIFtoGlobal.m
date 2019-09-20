% extent tiff to Global
% Linux
% 2019.9.16
% JiQiulei thrillerlemon@outlook.com
clear;close all;clc

%%  input
VAR_pt = 'E:\OFFICE\MTE_NEE_DATA\DEM_Data\elevation_MERIT_10km_FR.tif';
VARm = double(imread(VAR_pt));

%���ñ���ֵ
VARm(VARm==VARm(1,1)) = -9999;

%% Extend
%������ݵ�ȫ��,�����������������ݼ���
addrowUP=ones(31,4320)*-9999;
addrowDOWN=ones(335,4320)*-9999;
rasdata=[addrowUP;VARm;addrowDOWN];

%% out
Rmat = makerefmat('RasterSize',[2160,4320],...
    'Latlim',[-90 90], 'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');
geotiffwrite('E:\OFFICE\MTE_NEE_DATA\DEM_Data\elevation_MERIT_10km.tif', rasdata,Rmat);
disp('Finish!')
