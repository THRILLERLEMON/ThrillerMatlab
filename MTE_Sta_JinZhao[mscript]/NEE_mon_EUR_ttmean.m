% Calculate monthly NEE flux of Europe.
% 2017.4.5
clear;close all;clc;tic

%%  input

NEEm_pt = '/home/LiShuai/NEE_Train_for_upscale/Result';
fts = '_global_grass_NEE.tif';
[efrg1,efrg2] = deal(-5000,10000);
sf = 1;
[yr1,yr2] = deal(1982,2011);

EURmsk_fl = '/home/test2/MTE_NEE/OtherData/EUR_new_mask.tif';

grabl_fl = '/home/test2/MTE_NEE/OtherData/glc2000_10km_grass_bili.tif';

outtxt = '/home/test2/MTE_NEE/EURsts/EUR_mon_flux.txt';

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

EURrst = nan(yr2-yr1+1,12);
for yr = yr1:yr2
    disp(num2str(yr))
    for mn = 1:12
        tmp = double(imread([NEEm_pt,'/',...
            num2str(yr),num2str(mn,'%02d'),fts]));
        tmp(tmp<efrg1|tmp>efrg2) = nan;
        tmp = tmp(idx)*sf;
        wdarea2 = wdarea;
        wdarea2(isnan(tmp+wdarea+grabl)) = nan;
        EURrst(yr-yr1+1,mn) = nansum(tmp.*wdarea.*grabl)/nansum(wdarea2.*grabl);
        disp(num2str(mn))
    end
end

dlmwrite(outtxt,[(yr1:yr2)',EURrst],'delimiter',' ')

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])

