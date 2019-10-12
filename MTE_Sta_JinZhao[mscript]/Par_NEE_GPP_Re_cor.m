% Calculate the correlation coefficient between annual detrend NEE and GPP and Re.
% geotiff LINUX
% 2017.8.31
tic;close all;clear;clc

%%  input

GPP_pt = '/home/datastore/source/raster/Params/GPP/Global/1982_2011_MTE-GRASS-Density-5Min';
Re_pt = '/home/test2/MTE_NEE/Re/yflux';
NEE_pt = '/home/test2/MTE_NEE/NEE_new02/yflux';

yrs = [1982,2011];
bv = -99;
outpt = '/home/test2/MTE_NEE/NEE_new02/Cor/GPP_Re';

%%  operate

[m,n] = deal(1752,4320);
Rmat = makerefmat('RasterSize',[m n],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

disp('Reading')
GPPs = nan(m,n,yrs(2)-yrs(1)+1);
Res = nan(m,n,yrs(2)-yrs(1)+1);
NEEs = nan(m,n,yrs(2)-yrs(1)+1);
for yr = yrs(1):yrs(2)
    tmp1 = double(imread([GPP_pt,...
        '/MTE-GRASS_GPP_Density_',num2str(yr),'.tif']));
    tmp1(tmp1==tmp1(1,1)) = nan;
    GPPs(:,:,yr-yrs(1)+1) = tmp1;
    
    tmp2 = double(imread([Re_pt,'/Re_flux_',num2str(yr),'.tif']));
    tmp2(tmp2==tmp2(1,1)) = nan;
    Res(:,:,yr-yrs(1)+1) = tmp2;
    
    tmp3 = double(imread([NEE_pt,...
        '/NEEgra_FluxSum_',num2str(yr),'_01to12.tif']));
    tmp3(tmp3==tmp3(1,1)) = nan;
    NEEs(:,:,yr-yrs(1)+1) = tmp3;
    
    disp(num2str(yr))
end

parobj=parpool('local',16);
GPPcr = nan(m,n,2);
Recr = nan(m,n,2);
for ir = 1:m
    parfor ic = 1:n
        GPP3 = squeeze(GPPs(ir,ic,:));
        Re3 = squeeze(Res(ir,ic,:));
        NEE3 = squeeze(NEEs(ir,ic,:));
        idx = isnan(GPP3+Re3+NEE3);
        if sum(idx) <= 0.1*length(NEE3)
            GPP3(idx) = [];
            Re3(idx) = [];
            NEE3(idx) = [];
            
            GPP3 = detrend(GPP3);
            Re3 = detrend(Re3);
            NEE3 = detrend(NEE3);
            
            [R1,P1] = corrcoef(GPP3,NEE3);
            GPPcr(ir,ic,:) = [R1(1,2),P1(1,2)];
            [R1,P1] = corrcoef(Re3,NEE3);
            Recr(ir,ic,:) = [R1(1,2),P1(1,2)];
        end
    end
    disp(num2str(ir))
end
GPPcr(isnan(GPPcr)) = bv;
Recr(isnan(Recr)) = bv;

geotiffwrite([outpt,'/GPP_NEE_dtrd_R.tif'],single(GPPcr(:,:,1)),Rmat)
geotiffwrite([outpt,'/GPP_NEE_dtrd_P.tif'],single(GPPcr(:,:,2)),Rmat)
geotiffwrite([outpt,'/Re_NEE_dtrd_R.tif'],single(Recr(:,:,1)),Rmat)
geotiffwrite([outpt,'/Re_NEE_dtrd_P.tif'],single(Recr(:,:,2)),Rmat)

delete(parobj);
mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])
