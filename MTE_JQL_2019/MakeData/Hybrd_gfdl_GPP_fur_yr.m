% Extract yearly tiff from NC file
% Windows 10 1903
% 2019.9.11
% JiQiulei thrillerlemon@outlook.com
% ncread(nc�ļ�·����
% �������ƣ�
% ��������ÿһά��ʼ��ȡ��λ�ã�
% ��ָ����ʼ��ȡ��λ������ÿһάҪ��ȡ����Ŀ��
% ÿһάÿһ�ζ�ȡ�Ĳ���)
close all;clear;clc

NCfur_pt = 'C:\\Users\\thril\\Desktop\\MTEtest\\hybrid_gfdl-esm2m_rcp2p6_co2_gpp_annual_2006_2099.nc';
outpt = 'C:\\Users\\thril\\Desktop\\MTEtest';
%NC���ݵ���ʼ��
NCy = 2006;
%Ҫʹ�õ�NC���ݵı�������
vstr = 'gpp';

nrows = 360;
ncols = 720;
lats = [-90,90];
lons = [-180,180];
yrs = [2006,2010];
bv = -9999;


%mkdir(outpt)
%����һ���ռ��������Ϣ�������Ϊparam1, val1, param2, val2����ʽ
Rmat = makerefmat('RasterSize',[nrows,ncols],...
    'Latlim',[lats(1) lats(2)], 'Lonlim',[lons(1) lons(2)],...
    'ColumnsStartFrom','north');

hds = 'hybrid_gfdl-esm2m_co2_gpp';
for yr = yrs(1):yrs(2)
    ndys = 365;
    if mod(yr,400)==0||(mod(yr,4)==0 && mod(yr,100)~=0)
        ndys = 366;
    end
    tmp = double(ncread(NCfur_pt,vstr,...
        [1 1 yr-NCy+1],[ncols nrows 1],[1 1 1]));
    tmp(tmp==tmp(1,1)) = nan;
    tmp(tmp<0) = 0;
    tmp = tmp*1000*60*60*24*ndys;  % kg/m2/s --- g C/m2/yr
    tmp = tmp';
    tmp(isnan(tmp)) = -9999;
    
    geotiffwrite([outpt,'/',hds,'_',num2str(yr),'.tif'],single(tmp),Rmat)
    disp(num2str(yr))
end

disp('Finish!')
