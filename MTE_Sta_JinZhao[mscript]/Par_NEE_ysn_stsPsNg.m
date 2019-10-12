% Sum(PgC/yr) of global and regional NEE total.
% geotiff
% 2017.5.12
clear;close all;clc;tic

%%  Input

NEEysm_pt = '/home/test2/MTE_NEE/NEE_new02/ytotal';  % yearly NEE total

NEEsnysm = '/home/test2/MTE_NEE/NEE_new02/Season/SN_total';  % seasonal NEE total

clmgs_fl = '/home/test2/MTE_NEE/OtherData/Gras_Clim.tif';  % climate of grassland

outpt = '/home/test2/MTE_NEE/NEE_new02/Stat';

%%  Operate

yt_hd = 'NEEgra_FluxSum_';
yt_ft = '_01to12_total.tif';

sn_hd = 'NEEgra_TotalSum';
sn_ft = '_sum.tif';
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
yrst = nan(yr2-yr1+1,length(clmidx),2);
snyrst = nan(yr2-yr1+1,length(clmidx),4,2);
disp('start')
for yr = yr1:yr2
    ytt = double(imread([NEEysm_pt,'/',yt_hd,...
        num2str(yr),yt_ft]));
    ytt(ytt==ytt(1,1)) = nan;
    
    sny = [];
    for isn = 1:3+(yr~=yr2)
        sntmp = double(imread([NEEsnysm,'/',snstr{isn},'/',sn_hd,...
            num2str(yr),snstr{isn},sn_ft]));
        sntmp(sntmp==sntmp(1,1)) = nan;
        sny = cat(3,sny,sntmp);
    end
    
    for clm = 1:length(clmidx)
        ytt1 = ytt(clmidx{clm});
        yrst(yr-yr1+1,clm,1) = sum(ytt1(ytt1>0));
        yrst(yr-yr1+1,clm,2) = sum(ytt1(ytt1<0));
        
        for isn = 1:3+(yr~=yr2)
            sny1 = sny(:,:,isn);
            sny2 = sny1(clmidx{clm});
            snyrst(yr-yr1+1,clm,isn,1) = nansum(sny2(sny2>0));
            snyrst(yr-yr1+1,clm,isn,2) = nansum(sny2(sny2<0));
        end
    end
    disp(num2str(yr))
end

disp('write')
pn = {'Pos','Neg'};

for x = 1:2
    dlmwrite([outpt,'/NEEtotal_zone_',pn{x},'.txt'],...
        [[-99,uqclm',9999];[(yr1:yr2)',yrst(:,:,x)]],'delimiter',' ')
end

for x = 1:2
    for isn = 1:4
        dlmwrite([outpt,'/NEEtotal_',snstr{isn},'_zone_',pn{x},'.txt'],...
            [[-99,uqclm',9999];[(yr1:yr2)',snyrst(:,:,isn,x)]],...
            'delimiter',' ')
    end
end
mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])
