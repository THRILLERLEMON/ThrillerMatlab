% Calculate raster seasonal average or sum.
% geotiff, LINUX
% 2017.3.25

clear;clc;close all;tic

%%  doc month

NEEsn_pt = '/home/test2/MTE_NEE/NEE_new02/Season/SN_flux';
hds = 'NEEgra_FluxSum';
yr1 = 1982;
yr2 = 2011;

%%  parameter

vrnm = {'MAM','JJA','SON','DJF'};
bv = -9999;

[m,n] = deal(1752,4320);
Rmat = makerefmat('RasterSize',[m n],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

%%  Parallel

outpt = [NEEsn_pt,'/SNave'];
mkdir(outpt)

parobj=parpool('local',12);
parfor vr = 1:length(vrnm)
    ras_pt = [NEEsn_pt,'/',vrnm{vr}];
    
    % calculate
    if vr==4
        yr3=yr2-1;
    else
        yr3=yr2;
    end
    sndata = nan(m,n,yr3-yr1+1);
    for yr = yr1:yr3
        afs = dir([ras_pt,'/',hds,num2str(yr),'*.tif']);
        dtmp = double(imread([ras_pt,'/',afs.name]));
        dtmp(dtmp==dtmp(1,1)) = nan;  % back value
        sndata(:,:,yr-yr1+1) = dtmp;
    end
    ras_sts = nanmean(sndata,3);
    ras_sts(isnan(ras_sts)) = bv;
    
    % write
    geotiffwrite([outpt,'/',hds,'_',vrnm{vr},'_mean.tif'], ...
        single(ras_sts),Rmat)
    
    disp(vrnm{vr})
end
mins = toc;

delete(parobj);
disp(['Time:',num2str(mins/60),'minutes'])
