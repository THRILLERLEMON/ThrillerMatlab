% Linux
% 2019.10.4
% JiQiulei thrillerlemon@outlook.com
clear;clc;close all

%%  user

%%  input   –ﬁ∏ƒ’‚¿Ô
yearSE=[1982,2011];

ras_path = '/home/JiQiulei/MTE_JQL_2019/NEE_Upscale_NoIF_Sum2Year/Flux';
fhead='NoIF_FluxSum_';
ffoot='_01to12.tif';


prefix = 'NoIF_NEEFlux_';
outpath = '/home/JiQiulei/MTE_JQL_2019/NEE_Upscale_NoIF_Sum2Year';

valid = [-5000,20000];
sf = 1;
outbv = -9999;

stats = 1;  % 1.mean 2.sum 3.max 4.std

%%  calculate

fs = dir([ras_path,'/*.tif']);

Ginfo = geotiffinfo([ras_path,'/',fs(1).name]);


disp('Reading...')
rtmp = nan(Ginfo.Height, Ginfo.Width, yearSE(2)-yearSE(1)+1);
for y = yearSE(1):yearSE(2)
    temp = double(imread([ras_path,'/',fhead,num2str(y),ffoot]));
    temp(temp<valid(1) | temp>valid(2)) = nan;
    rtmp(:,:,y-yearSE(1)+1) = temp*sf;
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
geotiffwrite([outpath,'/',prefix,num2str(yearSE(1)),'-',num2str(yearSE(2)),'_',suffix{stats},'.tif'],single(rst),...
    Ginfo.RefMatrix,'GeoKeyDirectoryTag',Ginfo.GeoTIFFTags.GeoKeyDirectoryTag)

disp('Finish!')
