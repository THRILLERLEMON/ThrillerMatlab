% Sum or mean of global and regional PRP, TEM, SWR and FPAR.
% geotiff
% 2017.3.26
clear;close all;clc;tic

%%  Input

PRPy_pt = '/home/test2/MTE_NEE/MeteoData/Precipitation/ALL';
prphd = 'precipitation_';
prpft = 'year_10km.tif';

TEMy_pt = '/home/test2/MTE_NEE/MeteoData/Temperature';
temhd = '';
temft = '_10km.tif';

SWRy_pt = '/home/test2/MTE_NEE/MeteoData/SWrad';
swrhd = 'cruncepv5_swdown_';
swrft = '_10km.tif';

FPARy_pt = '/home/LiShuai/Data/MA_FAPAR1';
fparhd = 'MA_FAPAR_';
fparft = 'year.tif';

grabl_fl = '/home/test2/MTE_NEE/OtherData/glc2000_10km_grass_bili.tif';
clmgs_fl = '/home/test2/MTE_NEE/OtherData/Gras_Clim.tif';  % climate of grassland

outpt = '/home/test2/MTE_NEE/MeteoData/stats';

%%  Operate

disp('clm')
clmgs = double(imread(clmgs_fl));
clmgs(clmgs==clmgs(1,1)) = nan;
clmgs2 = clmgs(:);
clmgs2(isnan(clmgs2)) = [];
uqclm = unique(clmgs2(:));
clmidx = cell(length(uqclm)+1,1);
for clm = 1:length(uqclm)
    clmidx{clm} = find(clmgs==uqclm(clm));
end
clmidx{length(uqclm)+1} = find(~isnan(clmgs));
clearvars clmgs clmgs2

S1 = referenceSphere('earth','km');
wdzone = ones(1752,4320);
Rmat = makerefmat('RasterSize',[1752 4320],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');
[~,colarea] = areamat(wdzone,Rmat,S1);
wdarea = repmat(colarea,1,4320);

grabl = double(imread(grabl_fl));
grabl(grabl==grabl(1,1)) = nan;

[yr1,yr2] = deal(1982,2011);

yrst1 = nan(yr2-yr1+1,length(clmidx),4);  % PRP TEM SWR FPAR
yrst2 = nan(yr2-yr1+1,length(clmidx),4);
disp('start')
for yr = yr1:yr2
    disp(num2str(yr))
    
    PRP = double(imread([PRPy_pt,'/',prphd,num2str(yr),prpft]));
    PRP(PRP==PRP(1,1)) = nan;
    
    TEM = double(imread([TEMy_pt,'/',temhd,num2str(yr),temft]));
    TEM(TEM==TEM(1,1)) = nan;
    
    SWR = double(imread([SWRy_pt,'/',swrhd,num2str(yr),swrft]));
    SWR(SWR==SWR(1,1)) = nan;
    
    FPAR = double(imread([FPARy_pt,'/',fparhd,num2str(yr),fparft]));
    FPAR(FPAR==FPAR(1,1)) = nan;
    
    for clm = 1:length(clmidx)
        yrst1(yr-yr1+1,clm,1) = nanmean(PRP(clmidx{clm}));
        yrst1(yr-yr1+1,clm,2) = nanmean(TEM(clmidx{clm}));
        yrst1(yr-yr1+1,clm,3) = nanmean(SWR(clmidx{clm}));
        yrst1(yr-yr1+1,clm,4) = nanmean(FPAR(clmidx{clm}));
        
        wdarea2 = wdarea(clmidx{clm});
        wdarea2(isnan(PRP(clmidx{clm}))) = nan;
        yrst2(yr-yr1+1,clm,1) = nansum(PRP(clmidx{clm}).*...
            wdarea2.*grabl(clmidx{clm}))/...
            nansum(wdarea2.*grabl(clmidx{clm}));
        
        wdarea2 = wdarea(clmidx{clm});
        wdarea2(isnan(TEM(clmidx{clm}))) = nan;
        yrst2(yr-yr1+1,clm,2) = nansum(TEM(clmidx{clm}).*...
            wdarea2.*grabl(clmidx{clm}))/...
            nansum(wdarea2.*grabl(clmidx{clm}));
        
        wdarea2 = wdarea(clmidx{clm});
        wdarea2(isnan(SWR(clmidx{clm}))) = nan;
        yrst2(yr-yr1+1,clm,3) = nansum(SWR(clmidx{clm}).*...
            wdarea2.*grabl(clmidx{clm}))/...
            nansum(wdarea2.*grabl(clmidx{clm}));
        
        wdarea2 = wdarea(clmidx{clm});
        wdarea2(isnan(FPAR(clmidx{clm}))) = nan;
        yrst2(yr-yr1+1,clm,4) = nansum(FPAR(clmidx{clm}).*...
            wdarea2.*grabl(clmidx{clm}))/...
            nansum(wdarea2.*grabl(clmidx{clm}));
        
        disp(num2str(clm))
    end
end

disp('write')
vrstr = {'PRP','TEM','SWR','FPAR'};
for vr = 1:4
    dlmwrite([outpt,'/',vrstr{vr},'_zone.txt'],...
        [[-99,uqclm',9999];[(yr1:yr2)',yrst1(:,:,vr)]],'delimiter',' ')
    dlmwrite([outpt,'/',vrstr{vr},'_zoneArWt.txt'],...
        [[-99,uqclm',9999];[(yr1:yr2)',yrst2(:,:,vr)]],'delimiter',' ')
end

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])
