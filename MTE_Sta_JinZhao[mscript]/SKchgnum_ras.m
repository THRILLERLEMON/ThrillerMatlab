% Count the number of conversions bwtween carbon source and sink.
% geotiff
% JinZhao 2017.3.29
clear;close all;clc;tic

%%  Input

NEEflx_pt = '/home/test2/MTE_NEE/NEE_year/yflux';  % the full path of yearly NEE flux data
efrg  = [-5000, 5000];  % effective range
sf = 1;  % scale factor

bv = -99;
outhds = 'NEEgraFlux_SKchg';  % the prefix of output file
outpt = '/home/test2/MTE_NEE/NEE_year/PsNg_year';  % the path of output data

%%  Operate

afs = dir([NEEflx_pt,'/*.tif']);

[nrw,ncl] = deal(1752,4320);
Rmat = makerefmat('RasterSize',[nrw ncl],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

disp('Reading...')
rasall = nan(nrw,ncl,length(afs));
for fl = 1:length(afs)
    tmp = double(imread([NEEflx_pt,'/',afs(fl).name]));
    tmp(tmp<efrg(1) | tmp>efrg(2)) = nan;
    tmp = tmp*sf;
    rasall(:,:,fl) = tmp;
end

disp('DryWet:')
rst = nan(nrw,ncl,2);  % source to sink, sink to source
for ir = 1:nrw
    for ic = 1:ncl
        nee = squeeze(rasall(ir,ic,:));
        if all(~isnan(nee))
            [s2k_num,k2s_num] = SKchgnum(nee);
            rst(ir,ic,:) = ...
                reshape([s2k_num,k2s_num],[1 1 2]);
        end
    end
    disp([num2str(ir*100/nrw),'%'])
end
clearvars rasall
rst(isnan(rst)) = bv;

disp('Writing...')
outstr = {'S2Knum','K2Snum'};
for ix = 1:2
    geotiffwrite([outpt,'/',outhds,'_',outstr{ix},'.tif'],...
        rst(:,:,ix),Rmat)
end

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])
