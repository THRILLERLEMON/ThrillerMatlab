% Global and regional Met data.
% geotiff
% 2017.5.3
tic;clear;close all;clc

%%  Input

Mety_pt = '/home/test2/MTE_NEE/MeteoData/LAIer/yall';  % yearly Met
yt_hd = '';
yt_ft = '_ave_.tif';

Metsn_pt = '/home/test2/MTE_NEE/MeteoData/LAIer/Season';  % seasonal Met
sn_hd = 'LAIer';
sn_ft = '_mean.tif';

clmgs_fl = '/home/test2/MTE_NEE/OtherData/Gras_Clim.tif';  % climate of grassland

outhd = 'LAIer';
outpt = '/home/test2/MTE_NEE/MeteoData/stats/yr02';

%%  Operate

snstr = {'MAM','JJA','SON','DJF'};

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

[yr1,yr2] = deal(1982,2011);
yrst = nan(yr2-yr1+1,length(clmidx));
snyrst = nan(yr2-yr1+1,length(clmidx),4);
disp('start')
for yr = yr1:yr2
    ymet = double(imread([Mety_pt,'/',yt_hd,...
        num2str(yr),yt_ft]));
    ymet(ymet==ymet(1,1)) = nan;
    
    sny = [];
    for isn = 1:3+(yr~=yr2)
        sntmp = double(imread([Metsn_pt,'/',snstr{isn},'/',sn_hd,...
            num2str(yr),snstr{isn},sn_ft]));
        sntmp(sntmp==sntmp(1,1)) = nan;
        sny = cat(3,sny,sntmp);
    end
    
    for clm = 1:length(clmidx)
        yrst(yr-yr1+1,clm) = nanmean(ymet(clmidx{clm}));  %%
        for isn = 1:3+(yr~=yr2)
            sny1 = sny(:,:,isn);
            snyrst(yr-yr1+1,clm,isn) = nanmean(sny1(clmidx{clm}));  %%
        end
    end
    disp(num2str(yr))
end

disp('write')
dlmwrite([outpt,'/',outhd,'_zone.txt'],...
    [[-99,uqclm',9999];[(yr1:yr2)',yrst]],'delimiter',' ')
for isn = 1:4
    dlmwrite([outpt,'/',outhd,'_',snstr{isn},'_zone.txt'],...
        [[-99,uqclm',9999];[(yr1:yr2)',snyrst(:,:,isn)]],'delimiter',' ')
end

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])

