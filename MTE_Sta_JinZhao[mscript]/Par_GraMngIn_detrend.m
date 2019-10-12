% Detrend of yearly grassland management intensity.
% geotiff
% 2017.3.31
clear;close all;clc;tic

%%  input

GMI_pt = '/home/LiShuai/Data/Grass_Management/Intensive_frac';
outpt = '/home/test2/MTE_NEE/MeteoData/DETREND/IntensityFrac_no0';

%%  operate

bv = -99999;
[yr1,yr2] = deal(1982,2011);

efrg = [0,1];  % PRP TEM DwSr

[nrw,ncl] = deal(1752,4320);
Rmat = makerefmat('RasterSize',[nrw ncl],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

ytmps = [];
for yr = yr1:yr2
    tmp = double(imread([GMI_pt,'/',num2str(yr),'_Intensvie_frac.tif']));
    tmp(tmp<efrg(1)|tmp>efrg(2)) = nan;
    tmp = tmp(1:292,:)*100;  %%%%
    tmp = kron(tmp,ones(6,6));
    ytmps = cat(3,ytmps,tmp);
end

disp('Detrending...')
ydrd = nan(nrw,ncl,size(ytmps,3));
for ir = 1:nrw
    for ic = 1:ncl
        tmp1 = squeeze(ytmps(ir,ic,:));
        if all(tmp1~=0)
            tmp2 = detrend(tmp1);
            tmp2 = tmp2+tmp1(1)-tmp2(1);
            ydrd(ir,ic,:) = tmp2;
        end
    end
    disp(num2str(ir))
end
ydrd(isnan(ydrd)) = bv;

disp('Writing...')
for yr = yr1:yr2
    geotiffwrite([outpt,'/GMIF_detrendno0_',num2str(yr),'.tif'],...
        ydrd(:,:,yr-yr1+1),Rmat)
end

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])

