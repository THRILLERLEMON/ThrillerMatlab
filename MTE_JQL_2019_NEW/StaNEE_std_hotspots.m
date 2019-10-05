% 1.Calculate the STD of annual total NEE in 1982-2011.
% 2.Calculate the hot spots where the STD exceeds 
% the 75th, 90th, and 95th percentiles.
% Linux
% 2019.10.4
% JiQiulei thrillerlemon@outlook.com
%%  input
clear;clc;tic

NEEtotal_pt = '/home/JiQiulei/MTE_JQL_2019/NEE_Upscale_Sum2Year';
efrg = [-5000,10000];
sf = 1;
hds = '';
fts = 'NEEsum2Year_flux.tif';
yrs = [1982,2011];

outhd = 'NEESum2Year';
outpt = '/home/JiQiulei/MTE_JQL_2019/NEE_Sta';

%%  operate

[nrw,ncl] = deal(1752,4320);
Rmat = makerefmat('RasterSize',[nrw ncl],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

disp('Reading...')
rasall = nan(nrw,ncl,yrs(2)-yrs(1)+1);
for yr = yrs(1):yrs(2)
    tmp = double(imread([NEEtotal_pt,'/',hds,num2str(yr),fts]));
    tmp(tmp<efrg(1)|tmp>efrg(2)) = nan;
    rasall(:,:,yr-yrs(1)+1) = tmp*sf;
end

stdnee = std(rasall,0,3);

stdvc = stdnee(:);
stdvc(isnan(stdvc)) = [];
[std75,std90,std95] = deal(prctile(stdvc,75),...
    prctile(stdvc,90),prctile(stdvc,95));
idx00 = find(stdnee<=std75);
idx75 = find(stdnee>std75 & stdnee<=std90);
idx90 = find(stdnee>std90 & stdnee<=std95);
idx95 = find(stdnee>std95);

hotspt = nan(nrw,ncl);
hotspt(idx00) = 1;
hotspt(idx75) = 75;
hotspt(idx90) = 90;
hotspt(idx95) = 95;

stdnee(isnan(stdnee)) = -99;
hotspt(isnan(hotspt)) = -99;

geotiffwrite([outpt,'/',outhd,'_82to11_STD.tif'],single(stdnee),Rmat)
geotiffwrite([outpt,'/',outhd,'_82to11_Hotspots.tif'],int8(hotspt),Rmat)

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])

