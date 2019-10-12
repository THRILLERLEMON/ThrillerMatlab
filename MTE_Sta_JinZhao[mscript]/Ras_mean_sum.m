% geotiff
% 2015.5.31
clear;clc;close all

%%  user

ras_path = '/home/test2/MTE_NEE/NEE_new02/ytotal';

valid = [-5000,20000];
sf = 1;

stats = 1;  % 1.mean 2.sum 3.max 4.std

outbv = -9999;
prefix = 'NEEtt_82to11';
outpath = '/home/test2/MTE_NEE/NEE_new02/ymean';

%%  calculate

fs = dir([ras_path,'/*.tif']);

Ginfo = geotiffinfo([ras_path,'/',fs(1).name]);

disp('Reading...')
rtmp = nan(Ginfo.Height, Ginfo.Width, length(fs));
for i = 1:length(fs)
    temp = double(imread([ras_path,'/',fs(i).name]));
    temp(temp<valid(1) | temp>valid(2)) = nan;
    rtmp(:,:,i) = temp*sf;
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
rst(isnan(rst)) = outbv;
geotiffwrite([outpath,'/',prefix,'_',suffix{stats},'.tif'],single(rst),...
    Ginfo.RefMatrix,'GeoKeyDirectoryTag',Ginfo.GeoTIFFTags.GeoKeyDirectoryTag)

disp('Finish!')
