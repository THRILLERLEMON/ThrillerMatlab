% 1.Calculate the STD of annual total NEE in 1982-2011.
% 2.Calculate the hot spots where the STD exceeds 
% the 75th, 90th, and 95th percentiles.
% Linux
% 2019.10.4
% JiQiulei thrillerlemon@outlook.com
clear;close all;clc;tic

%%  input

NEEDataPath='/home/JiQiulei/MTE_JQL_2019/NEE_Upscale/';

efrg = [-5000,10000];
yrs = [1982,2011];

outhd = 'NEEyearly';
outpt = '/home/JiQiulei/MTE_JQL_2019/NEE_Sta/';

%%  operate

[nrw,ncl] = deal(1752,4320);
Rmat = makerefmat('RasterSize',[nrw ncl],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

disp('Reading...')
rasall = NaN(1752,4320,30);
for y = 1982:2011
    monthData=NaN(1752,4320,12);
    for m = 1:12
        if m < 10
            monthNEE=imread([NEEDataPath,num2str(y),'0',num2str(m),'_global_grass_NEE_MTEmean.tif']);
            monthNEE(monthNEE==monthNEE(1,1)) = nan;
            monthData(:,:,m)=monthNEE;
        else
            monthNEE=imread([NEEDataPath,num2str(y),num2str(m),'_global_grass_NEE_MTEmean.tif']);
            monthNEE(monthNEE==monthNEE(1,1)) = nan;
            monthData(:,:,m)=monthNEE;
        end
    end
    rasall(:,:,y-1982+1)=nansum(monthData,3);
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

geotiffwrite([outpt,'/',outhd,'_82to12_STD.tif'],single(stdnee),Rmat)
geotiffwrite([outpt,'/',outhd,'_82to12_Hotspots.tif'],int8(hotspt),Rmat)

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])
