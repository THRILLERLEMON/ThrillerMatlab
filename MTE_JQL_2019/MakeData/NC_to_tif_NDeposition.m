% Extract yearly tiff from NC file
% Windows 10 1903
% 2019.9.12
% JiQiulei thrillerlemon@outlook.com
% ncread(nc�ļ�·����
% �������ƣ�
% ��������ÿһά��ʼ��ȡ��λ�ã�
% ��ָ����ʼ��ȡ��λ������ÿһάҪ��ȡ����Ŀ��
% ÿһάÿһ�ζ�ȡ�Ĳ���)
close all;clear;clc

NC_pt = 'E:\OFFICE\MTE_NEE_DATA\Backup\N����\mstmip_driver_global_hd_nitrogen_nhx_v1.nc4';
outpt = 'E:\OFFICE\MTE_NEE_DATA\NHx_N_Deposition1982_2011';
%NC���ݵ���ʼ��
NCy = 1860;
%Ҫʹ�õ�NC���ݵı�������
vstr = 'NHx';

nrows = 360;
ncols = 720;
lats = [-90,90];
lons = [-180,180];
yrs = [1982,2011];
bv = -999;


%mkdir(outpt)
%����һ���ռ��������Ϣ�������Ϊparam1, val1, param2, val2����ʽ
Rmat = makerefmat('RasterSize',[nrows,ncols],...
    'Latlim',[lats(1) lats(2)], 'Lonlim',[lons(1) lons(2)],...
    'ColumnsStartFrom','north');

hds = 'NHx_N_Deposition';
for yr = yrs(1):yrs(2)
    tmp = double(ncread(NC_pt,vstr,...
        [1 1 yr-NCy+1],[ncols nrows 1],[1 1 1]));
    tmp(tmp==bv) = -9999;
    tmp = tmp';
    geotiffwrite([outpt,'\',hds,'_',num2str(yr),'.tif'],tmp,Rmat)
    disp(num2str(yr))
end

disp('Finish!')
