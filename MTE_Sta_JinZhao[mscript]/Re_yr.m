% Calculate yearly Re density by substracting NEE from GPP.
% geotiff LINUX
% 2017.8.31
tic;close all;clear;clc

%%  input

GPP_pt = '/home/datastore/source/raster/Params/GPP/Global/1982_2011_MTE-GRASS-Density-5Min';
NEE_pt = '/home/test2/MTE_NEE/NEE_new02/yflux';

yrs = [1982,2011];
outpt = '/home/test2/MTE_NEE/Re/yflux';

%%  operate

Rmat = makerefmat('RasterSize',[1752 4320],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

for yr = yrs(1):yrs(2)
    GPP = double(imread([GPP_pt,...
        '/MTE-GRASS_GPP_Density_',num2str(yr),'.tif']));
    GPP(GPP==GPP(1,1)) = nan;
    NEE = double(imread([NEE_pt,...
        '/NEEgra_FluxSum_',num2str(yr),'_01to12.tif']));
    NEE(NEE==NEE(1,1)) = nan;
    Re = GPP+NEE;
    Re(isnan(Re)) = -9999;
    
    geotiffwrite([outpt,'/Re_flux_',num2str(yr),'.tif'],single(Re),Rmat)
    disp(num2str(yr))
end

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])
