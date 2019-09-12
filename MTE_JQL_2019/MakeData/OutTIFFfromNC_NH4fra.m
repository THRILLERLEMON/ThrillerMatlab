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

NCfur_pt = 'E:\\OFFICE\\MTE_NEE_DATA\\1961 - 2010���ڼ��µ���ʷȫ�򵪷�ʩ��ͼ\\FAOSTAT_ver1\\NH4_fraction_ver1.nc4';
outpt = 'E:\\OFFICE\\MTE_NEE_DATA\\1961 - 2010���ڼ��µ���ʷȫ�򵪷�ʩ��ͼ\\FAOSTAT_ver1\\NH4_fraction_TIFF';
%NC���ݵ���ʼ��
NCy = 1961;
%Ҫʹ�õ�NC���ݵı�������
vstr = 'NH4_frac';

nrows = 360;
ncols = 720;
lats = [-90,90];
lons = [-180,180];
yrs = [1998,2006];
bv = -9999;


%mkdir(outpt)
%����һ���ռ��������Ϣ�������Ϊparam1, val1, param2, val2����ʽ
Rmat = makerefmat('RasterSize',[nrows,ncols],...
    'Latlim',[lats(1) lats(2)], 'Lonlim',[lons(1) lons(2)],...
    'ColumnsStartFrom','north');

hds = 'NH4_frac';
for yr = yrs(1):yrs(2)
    tmp = double(ncread(NCfur_pt,vstr,...
        [1 1 yr-NCy+1],[ncols nrows 1],[1 1 1]));
    tmp(tmp==tmp(1,1)) = nan;
    tmp(isnan(tmp)) = -9999;
    tmp = tmp';
    geotiffwrite([outpt,'\',hds,'_',num2str(yr),'.tif'],tmp,Rmat)
    disp(num2str(yr))
end

disp('Finish!')
