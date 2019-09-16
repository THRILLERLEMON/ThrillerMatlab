% extent tiff to Global
% Linux
% 2019.9.16
% JiQiulei thrillerlemon@outlook.com
clear;close all;clc

%%  input
VAR_pt = '/home/JiQiulei/MTE_JQL_2019/MakeData/GSOCmap1.5.0.tif';
%栅格像元的大小
rsize = 1/120;
VARm = double(imread(VAR_pt));
%设置背景值
VARm(VARm==VARm(1,1)) = -9999;

%% Extend
%填充数据到全球,具体数量，根据数据计算
addrowUP=ones(766,43200)*-9999;
addrowDOWN=ones(2290,43200)*-9999;
rasdata=[addrowUP;VARm;addrowDOWN];
%先令元数据中的0值为0.01，元数据中0值很少，且0.01值很小
rasdata(rasdata==0) = 0.01;
%令背景值为0，方便resize
rasdata(rasdata==-9999) = 0;
%bilinear为双线性插值；bicubic为双三次插值
rasdata10KM=imresize(rasdata,0.1,'bilinear');
%设置背景值
rasdata10KM(rasdata10KM==0) = -9999;
rasdata10KM(rasdata10KM<0) = -9999;

%% out
Rmat = makerefmat('RasterSize',[2160,4320],...
    'Latlim',[-90 90], 'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');
geotiffwrite('/home/JiQiulei/MTE_JQL_2019/MakeData/GSOCmap1.5.0_Extend10KM_bil.tif', rasdata10KM,Rmat);
% save('E:\OFFICE\MTE_NEE_DATA\GSOC\GSOCmap_Extend.mat', 'rasdata','-v7.3')
% [nrows,ncols]=size(rasdata10KM);
% disp(nrows)
% disp(ncols)
disp('Finish!')
