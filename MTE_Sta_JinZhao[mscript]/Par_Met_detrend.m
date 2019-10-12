% Detrend of yearly meteological data.
% geotiff
% 2017.3.31
clear;close all;clc;tic

%%  input

Met_pt = '/home/test2/MTE_NEE/MeteoData';

%%  operate

bv = -99999;
[yr1,yr2] = deal(1982,2011);

efrg = [[0,20000];[-50,50];[0,20000]];  % PRP TEM DwSr
efrg1 = efrg(:,1);
efrg2 = efrg(:,2);

[nrw,ncl] = deal(1752,4320);
Rmat = makerefmat('RasterSize',[nrw ncl],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

Mdoc_str = {'Precipitation','Temperature','SWrad'};
for imt=1:3
    mkdir([Met_pt,'/DETREND'],Mdoc_str{imt})
end

mthds = {'precipitation_','','cruncepv5_swdown_'};
mtfts = {'year_10km.tif','_10km.tif','_10km.tif'};

parobj=parpool('local',15);
parfor imt = 1:3
    metpt = [Met_pt,'/',Mdoc_str{imt}];
    mhd = mthds{imt};
    mft = mtfts{imt};
    outpt = [Met_pt,'/DETREND/',Mdoc_str{imt}];
    
    ytmps = [];
    for yr = yr1:yr2
        tmp = double(imread([metpt,'/',mhd,num2str(yr),mft]));
        tmp(tmp<efrg1(imt)|tmp>efrg2(imt)) = nan;
        ytmps = cat(3,ytmps,tmp);
    end
    
    ydrd = nan(nrw,ncl,size(ytmps,3));
    for ir = 1:nrw
        tmp1 = ytmps(ir,:,:);
        tmp1 = permute(tmp1,[3,2,1]);
        tmp2 = detrend(tmp1);
        tmp2 = tmp2+repmat(tmp1(1,:)-tmp2(1,:),size(tmp2,1),1);
        tmp2 = permute(tmp2,[3,2,1]);        
        ydrd(ir,:,:) = tmp2;
    end
    ydrd(isnan(ydrd)) = bv;
    
    for yr = yr1:yr2
        geotiffwrite([outpt,'/',mhd,num2str(yr),mft],...
            ydrd(:,:,yr-yr1+1),Rmat)
    end
    
    disp(Mdoc_str{imt})
end
delete(parobj);

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])

