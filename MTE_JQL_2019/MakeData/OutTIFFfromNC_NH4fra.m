% Extract yearly tiff from NC file
% Windows 10 1903
% 2019.9.12
% JiQiulei thrillerlemon@outlook.com
% ncread(nc文件路径，
% 变量名称，
% 变量数据每一维开始读取的位置，
% 从指定开始读取的位置算起，每一维要读取的数目，
% 每一维每一次读取的步长)
close all;clear;clc

NCfur_pt = 'E:\\OFFICE\\MTE_NEE_DATA\\1961 - 2010年期间新的历史全球氮肥施用图\\FAOSTAT_ver1\\NH4_fraction_ver1.nc4';
outpt = 'E:\\OFFICE\\MTE_NEE_DATA\\1961 - 2010年期间新的历史全球氮肥施用图\\FAOSTAT_ver1\\NH4_fraction_TIFF';
%NC数据的起始年
NCy = 1961;
%要使用的NC数据的变量名称
vstr = 'NH4_frac';

nrows = 360;
ncols = 720;
lats = [-90,90];
lons = [-180,180];
yrs = [1998,2006];
bv = -9999;


%mkdir(outpt)
%构建一个空间坐标的信息矩阵参数为param1, val1, param2, val2的形式
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
