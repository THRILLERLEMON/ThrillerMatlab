% Sum(PgC/yr) of global and regional NEE total.
% geotiff
% 2017.3.26
clear;close all;clc;tic

%%  Input

NEEysm_pt = '/home/JiQiulei/MTE_JQL_2019/NEE_Upscale_NoIF_Sum2Year/Total';  % yearly NEE total

NEEsnysm = '/home/JiQiulei/MTE_JQL_2019/NEE_Upscale_Sum2Season/SN_total';  % seasonal NEE total

clmgs_fl = '/home/test2/MTE_NEE/OtherData/Gras_Clim.tif';  % climate of grassland

outpt = '/home/JiQiulei/MTE_JQL_2019/NEE_Sta';

%%  Operate

yt_hd = 'NoIF_FluxSum_';
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
yrst = nan(yr2-yr1+1,length(clmidx));
snyrst = nan(yr2-yr1+1,length(clmidx),4);
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
        yrst(yr-yr1+1,clm) = nansum(ytt(clmidx{clm}));
        for isn = 1:3+(yr~=yr2)
            sny1 = sny(:,:,isn);
            snyrst(yr-yr1+1,clm,isn) = nansum(sny1(clmidx{clm}));
        end
    end
    disp(num2str(yr))
end

disp('write')
dlmwrite([outpt,'/',num2str(yr1),'-',num2str(yr2),'NoIF_NEEtotal_zone_SUM.txt'],...
    [[-99,uqclm',9999];[(yr1:yr2)',yrst]],'delimiter',' ')
% for isn = 1:4
%     dlmwrite([outpt,'/',num2str(yr1),'-',num2str(yr2),'NEEtotal_',snstr{isn},'_zone_MEAN.txt'],...
%         [[-99,uqclm',9999];[(yr1:yr2)',snyrst(:,:,isn)]],'delimiter',' ')
% end

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])
