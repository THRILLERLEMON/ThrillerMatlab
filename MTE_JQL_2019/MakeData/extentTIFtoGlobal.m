% extent tiff to Global
% Windows 10 1903
% 2019.9.12
% JiQiulei thrillerlemon@outlook.com
clear;close all;clc

%%  input
VAR_pt = 'E:\OFFICE\MTE_NEE_DATA\GSOC\GSOCmap1.5.0.tif';
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

%% out
Rmat = makerefmat('RasterSize',[21600,43200],...
    'Latlim',[-90 90], 'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');
% geotiffwrite('E:\OFFICE\MTE_NEE_DATA\GSOC\GSOCmap1.5.0_Extend.tif', rasdata,Rmat);
save('E:\OFFICE\MTE_NEE_DATA\GSOC\GSOCmap_Extend.mat', 'rasdata','-v7.3')
[nrows,ncols]=size(rasdata);
disp(nrows)
disp(ncols)
disp('Finish!')
