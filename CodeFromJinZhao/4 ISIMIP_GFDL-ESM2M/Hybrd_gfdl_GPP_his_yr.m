% hybrid_gfdl-esm2m_hist_co2_gpp_annual_1971_2005
% Extract yearly GPP flux
% LINUX
% 2017.9.28
close all;clear;clc

%%  input

NC_fl = 'D:\Gfdl-esm2m\GPP\hist\hybrid_gfdl-esm2m_hist_co2_gpp_annual_1971_2005.nc';
NCy = 1971;
vstr = 'gpp';

nrows = 360;
ncols = 720;

lats = [-90,90];
lons = [-180,180];

yrs = [1971,2005];

hds = 'hybrid_gfdl-esm2m_hist_co2_gpp';
bv = -9999;
outpt = 'D:\Gfdl-esm2m_extract\GPP_yr\hybrid_hist';

%%  operate

mkdir(outpt)
Rmat = makerefmat('RasterSize',[nrows,ncols],...
    'Latlim',[lats(1) lats(2)], 'Lonlim',[lons(1) lons(2)],...
    'ColumnsStartFrom','north');

for yr = yrs(1):yrs(2)
    ndys = 365;
    if mod(yr,400)==0||(mod(yr,4)==0 && mod(yr,100)~=0)
        ndys = 366;
    end
    tmp = double(ncread(NC_fl,vstr,...
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
