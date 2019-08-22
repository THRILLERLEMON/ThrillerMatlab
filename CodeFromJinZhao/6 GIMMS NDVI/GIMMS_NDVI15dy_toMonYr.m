% GIMMS NDVI 15day, MVC合成月数据, 生长季平均计算年数据, 以及FC
% GeoTIFF
% JZ 2018.4.21
close all;clear;clc

%%  input

NDVI15d_pt = 'G:\GIMMS_NDVI3g\LPsqr_int2';
hd = 'ndvi3g_geo_v1_';
ft = '_LP.tif';
vd = [0,10000];
sf = 1;

[yr1,yr2] = deal(1981,1981);
[mon1,mon2] = deal(4,10);

bv = -99;
outpt = 'E:\GIMMS_NDVI3g\LPsqr_int_YM2';

%%  operate

afs = dir([NDVI15d_pt,filesep,'*.tif']);
afs = [NDVI15d_pt,filesep,afs(1).name];
Ginfo = geotiffinfo(afs);
Rmat = Ginfo.RefMatrix;
Rtag = Ginfo.GeoTIFFTags.GeoKeyDirectoryTag;
[m,n] = deal(Ginfo.Height,Ginfo.Width);

outptm = [outpt,filesep,'month'];
if ~exist(outptm,'dir')
    mkdir(outptm)
end
outpty = [outpt,filesep,'year'];
if ~exist(outpty,'dir')
    mkdir(outpty)
end

mstr = {'a','b'};
for yr = yr1:yr2
    NDVIyr = zeros(m,n);
    idxv = zeros(m,n);
    for imn = 1:12
        NDVIm = nan(m,n,2);
        for idy = 1:2
            tmp = double(imread([NDVI15d_pt,filesep,hd,...
                num2str(yr),num2str(imn,'%02d'),mstr{idy},ft]));
            tmp(tmp<vd(1)|tmp>vd(2)) = nan;
            tmp = tmp*sf;
            NDVIm(:,:,idy) = tmp;
        end
        NDVIm = max(NDVIm,[],3);
        if imn>=mon1&&imn<=mon2
            NDVIyr = nansum(cat(3,NDVIyr,NDVIm),3);
            idxv = sum(cat(3,idxv,~isnan(NDVIm)),3);
        end
        NDVIm(isnan(NDVIm)) = bv;
        geotiffwrite([outptm,filesep,hd,num2str(yr),...
            num2str(imn,'%02d'),ft],single(NDVIm),...
            Rmat,'GeoKeyDirectoryTag',Rtag)
        
        clc
        disp([num2str(yr),' ',num2str(imn)])
    end
    NDVIyr = NDVIyr./idxv;
    NDVIyr(idxv==0) = bv;
    geotiffwrite([outpty,filesep,hd,num2str(yr),...
        '_',num2str(mon1,'%02d'),'to',num2str(mon2,'%02d'),ft],...
        single(NDVIyr),Rmat,'GeoKeyDirectoryTag',Rtag)
end

disp('Finish!')
