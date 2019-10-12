% Calculate variances of GPP and Re, and covariance between them.
% geotiff LINUX
% 2017.8.31
tic;close all;clear;clc

%%  input

GPP_pt = '/home/datastore/source/raster/Params/GPP/Global/1982_2011_MTE-GRASS-Density-5Min';
Re_pt = '/home/test2/MTE_NEE/Re/yflux';

bv = -9999;
yrs = [1982,2011];
outpt = '/home/test2/MTE_NEE/CovVar/yflux';

%%  operate

[m,n] = deal(1752,4320);
Rmat = makerefmat('RasterSize',[m n],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

disp('Reading')
GPPs = nan(m,n,yrs(2)-yrs(1)+1);
Res = nan(m,n,yrs(2)-yrs(1)+1);
for yr = yrs(1):yrs(2)
    GPP = double(imread([GPP_pt,...
        '/MTE-GRASS_GPP_Density_',num2str(yr),'.tif']));
    GPP(GPP==GPP(1,1)) = nan;
    GPPs(:,:,yr-yrs(1)+1) = GPP;
    
    Re = double(imread([Re_pt,'/Re_flux_',num2str(yr),'.tif']));
    Re(Re==Re(1,1)) = nan;
    Res(:,:,yr-yrs(1)+1) = Re;
    
    disp(num2str(yr))
end

parobj=parpool('local',16);
GPPvr = nan(m,n);
Revr = nan(m,n);
Ng2Cv = nan(m,n);
for ir = 1:m
    parfor ic = 1:n
        GPP3 = squeeze(GPPs(ir,ic,:));
        Re3 = squeeze(Res(ir,ic,:));
        idx = isnan(GPP3+Re3);
        if sum(idx) <= 0.1*length(GPP3)
            GPP3(idx) = [];
            Re3(idx) = [];
            
            GPPvr(ir,ic) = var(GPP3);
            Revr(ir,ic) = var(Re3);
            cvs = cov(GPP3,Re3);
            Ng2Cv(ir,ic) = -2*cvs(1,2);
        end
    end
    disp(num2str(ir))
end
delete(parobj);
GPPvr(isnan(GPPvr)) = bv;
Revr(isnan(Revr)) = bv;
Ng2Cv(isnan(Ng2Cv)) = bv;

yrstr = ['_',num2str(yrs(1)),'to',num2str(yrs(2)),'.tif'];
geotiffwrite([outpt,'/GPP_var',yrstr],...
    single(GPPvr),Rmat)
geotiffwrite([outpt,'/Re_var',yrstr],...
    single(Revr),Rmat)
geotiffwrite([outpt,'/GPP_Re_Ng2cvar',yrstr],...
    single(Ng2Cv),Rmat)

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])

