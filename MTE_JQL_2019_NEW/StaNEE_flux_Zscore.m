% Calculate Z-score of NEE flux at 2002, 2003 and 2005.
% 2017.4.4
clear;close all;clc

%%  input

NEEflx_pt = '/home/JiQiulei/MTE_JQL_2019/NEE_Upscale_Sum2Year/Flux';
hds = 'NEEgra_FluxSum_';
fts = '_01to12.tif';

NEEave_fl = '/home/JiQiulei/MTE_JQL_2019/NEE_Sta/NEEFlux_1997-2001_mean.tif';
NEEstd_fl = '/home/JiQiulei/MTE_JQL_2019/NEE_Sta/NEEFlux_1997-2001_std.tif';

bv = -9999;
NEEzsc_pt = '/home/JiQiulei/MTE_JQL_2019/NEE_Sta';

%%  operate

[m,n] = deal(1752,4320);
Rmat = makerefmat('RasterSize',[m n],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

yrs = [2002,2003,2005];

NEEave = imread(NEEave_fl);
NEEave(NEEave==NEEave(1,1)) = nan;

NEEstd = imread(NEEstd_fl);
NEEstd(NEEstd==NEEstd(1,1)) = nan;

for yr = 1:length(yrs)
    tmp = imread([NEEflx_pt,'/',hds,num2str(yrs(yr)),fts]);
    tmp(tmp==tmp(1,1)) = nan;
    tmp = (tmp-NEEave)./NEEstd;
    tmp(isnan(tmp)) = bv;
    geotiffwrite([NEEzsc_pt,'/NEE_Zscore_97to01_',...
        num2str(yrs(yr)),'.tif'],single(tmp),Rmat)
    disp(num2str(yrs(yr)))
end

disp('Finish!')
