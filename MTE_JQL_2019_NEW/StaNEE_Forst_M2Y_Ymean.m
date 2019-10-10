% Linux
% 2019.10.4
% JiQiulei thrillerlemon@outlook.com
clear;close all;clc;tic


NEEm_pt = '/home/LiShuai/Data/Frost_day_frequency';

ygap = [1982,2011];
mgap = [1,12];
efrg = [-5000,10000];
sf = 1;
hds = 'cru_ts3.22_';
fts = '.tif';

prefix = 'Frost_day_frequency_82-11_';
outpath = '/home/JiQiulei/MTE_JQL_2019/NEE_Sta';

%%  operate
stats = 1;  % 1.mean 2.sum 3.max 4.std

Rmat = makerefmat('RasterSize',[360 720],...
    'Latlim',[-90 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');
nrow = 360;
ncol = 720;

efrg1 = efrg(1);
efrg2 = efrg(2);
mgp1 = mgap(1);
mgp2 = mgap(2);

rtmp = nan(nrow,ncol, ygap(2)-ygap(1)+1);
for yr = ygap(1):ygap(2)
    ytmp = zeros(nrow,ncol);
    idx = zeros(nrow,ncol);
    for mth = mgp1:mgp2
        mtmp = double(imread([NEEm_pt,'/',...
            hds,num2str(yr),num2str(mth,'%02d'),fts]));
        mtmp(mtmp==mtmp(1,1)) = nan;
        mtmp = mtmp*sf;
        ytmp = nansum(cat(3,ytmp,mtmp),3);  %%%
        idx = sum(cat(3,idx,~isnan(mtmp)),3);
    end
    ytmp(idx==0) = nan;
    rtmp(:,:,yr-ygap(1)+1) = ytmp;
end

switch stats
case 1
    rst = nanmean(rtmp,3);
case 2
    rst = sum(rtmp,3);
case 3
    rst = nanmax(rtmp,[],3);
case 4
    rst = nanstd(rtmp,0,3);
otherwise
    errordlg('bad stats!','stats error')
end
suffix = {'mean','sum','max','std'};

rst(sum(~isnan(rtmp),3)==0) = nan;
rst(isnan(rst)) = -9999;
geotiffwrite([outpath,'/',prefix,'_',suffix{stats},'.tif'],single(rst),Rmat);


disp('Finish!');