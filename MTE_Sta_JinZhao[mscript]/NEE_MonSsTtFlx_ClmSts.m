% Mean of seasonal and monthly NEE total and NEE flux in global and regional scale.
% geotiff
% 2017.4.13
tic;clear;close all;clc

%%  input

NEEmn_pt = '/home/test2/MTE_NEE/NEE_new/month';  % monthly flux
mfts = '_global_grass_NEE.tif';

NEEsn_pt = '/home/test2/MTE_NEE/NEE_new/Season/SN_total';  % seasonal total
shds = 'NEEgra_TotalSum';

grabl_fl = '/home/test2/MTE_NEE/OtherData/glc2000_10km_grass_bili.tif';
clmgs_fl = '/home/test2/MTE_NEE/OtherData/Gras_Clim.tif';  % climate of grassland

outpt = '/home/test2/MTE_NEE/NEE_new/Clm_Stats';

[yr1,yr2] = deal(1982,2011);
[mn1,mn2] = deal(1,12);

%%  operate

[m,n] = deal(1752,4320);
S1 = referenceSphere('earth','km');
wdzone = ones(m,n);
Rmat = makerefmat('RasterSize',[m n],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');
[~,colarea] = areamat(wdzone,Rmat,S1);
wdarea = repmat(colarea,1,4320);

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

grabl = double(imread(grabl_fl));
grabl(grabl==grabl(1,1)) = nan;

snstr = {'MAM','JJA','SON','DJF'};
for isn = 1:length(snstr)
    disp(snstr{isn})
    snrst = nan(yr2-yr1+1,length(clmidx),2);  % total sum, flux
    for yr = yr1:yr2
        flnm = [NEEsn_pt,'/',snstr{isn},'/',...
            shds,num2str(yr),snstr{isn},'_sum.tif'];
        if exist(flnm,'file')
            sntmp = double(imread(flnm));
            sntmp(sntmp==sntmp(1,1)) = nan;
            for clm = 1:length(clmidx)
                NEEtt = sntmp(clmidx{clm});
                wdarea1 = wdarea(clmidx{clm});
                wdarea1(isnan(NEEtt)) = nan;
                grabl1 = grabl(clmidx{clm});
                
                snrst(yr-yr1+1,clm,1) = nansum(NEEtt);
                snrst(yr-yr1+1,clm,2) = nansum(NEEtt)*10^9/...
                    (nansum(wdarea1.*grabl1));
            end
        end
        disp(num2str(yr))
    end
    dlmwrite([outpt,'/NEEttsum_',snstr{isn},'.txt'],...
        [(yr1:yr2)',snrst(:,:,1)],'delimiter',' ')
    dlmwrite([outpt,'/NEEflux_',snstr{isn},'.txt'],...
        [(yr1:yr2)',snrst(:,:,2)],'delimiter',' ')
    
    disp(snstr{isn})
end

clmflx = nan(yr2-yr1+1,mn2-mn1+1,length(clmidx));
clmtt = nan(yr2-yr1+1,mn2-mn1+1,length(clmidx));
for yr = yr1:yr2
    disp(num2str(yr))
    for mn = mn1:mn2
        mtmp = double(imread([NEEmn_pt,'/',...
            num2str(yr),num2str(mn,'%02d'),mfts]));
        mtmp(mtmp==mtmp(1,1)) = nan;
        
        for clm = 1:length(clmidx)
            mclm = mtmp(clmidx{clm});
            
            wdarea1 = wdarea(clmidx{clm});
            wdarea1(isnan(mclm)) = nan;
            grabl1 = grabl(clmidx{clm});
            
            clmtt(yr-yr1+1,mn,clm) = nansum(mclm.*wdarea1.*grabl1)/10^9;
            clmflx(yr-yr1+1,mn,clm) = nansum(mclm.*wdarea1.*grabl1)/...
                nansum(wdarea1.*grabl1);
        end
        disp(num2str(mn))
    end
end

for clm = 1:length(clmidx)
    dlmwrite([outpt,'/NEE_mtotal',num2str(clm,'%02d'),'.txt'],...
        [(yr1:yr2)',clmtt(:,:,clm)],'delimiter',' ')
    dlmwrite([outpt,'/NEE_mflux',num2str(clm,'%02d'),'.txt'],...
        [(yr1:yr2)',clmflx(:,:,clm)],'delimiter',' ')
end

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])
