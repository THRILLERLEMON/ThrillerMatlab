% extent tiff to Global
% Linux
% 2019.9.16
% JiQiulei thrillerlemon@outlook.com
clear;close all;clc

%%  input
VAR_pt = '/home/JiQiulei/MTE_JQL_2019/MakeData/GSOCmap1.5.0.tif';
%դ����Ԫ�Ĵ�С
rsize = 1/120;
VARm = double(imread(VAR_pt));
%���ñ���ֵ
VARm(VARm==VARm(1,1)) = -9999;

%% Extend
%������ݵ�ȫ��,�����������������ݼ���
addrowUP=ones(766,43200)*-9999;
addrowDOWN=ones(2290,43200)*-9999;
rasdata=[addrowUP;VARm;addrowDOWN];
%����Ԫ�����е�0ֵΪ0.01��Ԫ������0ֵ���٣���0.01ֵ��С
rasdata(rasdata==0) = 0.01;
%���ֵΪ0������resize
rasdata(rasdata==-9999) = 0;
%bilinearΪ˫���Բ�ֵ��bicubicΪ˫���β�ֵ
rasdata10KM=imresize(rasdata,0.1,'bilinear');
%���ñ���ֵ
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
