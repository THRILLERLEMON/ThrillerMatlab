% Calculate annual NEE total of Europe.
% 2017.4.6
clear;close all;clc;tic

%%  input

NEEytt_pt = '/home/test2/MTE_NEE/NEE_new02/ytotal';
hds = 'NEEgra_FluxSum_';
fts = '_01to12_total.tif';
[vd1,vd2] = deal(-5000,10000);
sf = 1;
[yr1,yr2] = deal(1982,2011);

EURmsk_fl = '/home/test2/MTE_NEE/OtherData/EUR27_ras.tif';
grabl_fl = '/home/test2/MTE_NEE/OtherData/glc2000_10km_grass_bili.tif';

outpt = '/home/test2/MTE_NEE/NEE_new02/EURsts';

%%  operate

EURmsk = double(imread(EURmsk_fl));
idx = find(EURmsk==1);

S1 = referenceSphere('earth','km');
wdzone = ones(1752,4320);
Rmat = makerefmat('RasterSize',[1752 4320],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');
[~,colarea] = areamat(wdzone,Rmat,S1);
wdarea = repmat(colarea,1,4320);
wdarea = wdarea(idx);

grabl = double(imread(grabl_fl));
grabl(grabl==grabl(1,1)) = nan;
grabl = grabl(idx);

EURflx = nan(yr2-yr1+1,1);
EURtt = nan(yr2-yr1+1,1);
for yr = yr1:yr2
    disp(num2str(yr))
    tmp = double(imread([NEEytt_pt,'/',hds,num2str(yr),fts]));
    tmp(tmp<vd1|tmp>vd2) = nan;
    tmp = tmp(idx)*sf;
    wdarea2 = wdarea;
    wdarea2(isnan(tmp+wdarea+grabl)) = nan;
    
    EURtt(yr-yr1+1,1) = nansum(tmp);
    EURflx(yr-yr1+1,1) = nansum(tmp)*10^9/nansum(wdarea2.*grabl);
    disp(num2str(yr))
end

dlmwrite([outpt,'/EUR_tt_yr.txt'],[(yr1:yr2)',EURtt],'delimiter',' ')
dlmwrite([outpt,'/EUR_flux_yr.txt'],[(yr1:yr2)',EURflx],'delimiter',' ')

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])

