% hybrid_gfdl-esm2m_rcp2p6_co2_gpp_annual_2006_2099
% Extract yearly GPP flux
% LINUX
% 2017.9.25
close all;clear;clc

%%  input

NCfur_pt = 'D:\Gfdl-esm2m\GPP\hybrid';
% scns = {'rcp2p6','rcp4p5','rcp6p0','rcp8p5'};
scns = {'rcp2p6','rcp6p0','rcp8p5'};

NCy = 2006;
vstr = 'gpp';

nrows = 360;
ncols = 720;

lats = [-90,90];
lons = [-180,180];

yrs = [2006,2099];

bv = -9999;
outpt = 'D:\Gfdl-esm2m_extract\GPP_yr\hybrid_fur';

%%  parameter

mkdir(outpt)
Rmat = makerefmat('RasterSize',[nrows,ncols],...
    'Latlim',[lats(1) lats(2)], 'Lonlim',[lons(1) lons(2)],...
    'ColumnsStartFrom','north');

for sc = 1:length(scns)
    NC_fl = [NCfur_pt,'\hybrid_gfdl-esm2m_',scns{sc},'_co2_gpp_annual_2006_2099.nc'];
    hds = ['hybrid_gfdl-esm2m_',scns{sc},'_co2_gpp'];
    
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
        disp([scns{sc},' ',num2str(yr)])
    end
end
disp('Finish!')
