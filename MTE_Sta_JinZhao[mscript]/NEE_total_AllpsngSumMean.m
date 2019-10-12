% Calculate sum of annual total NEE total grids where are always source or sink.
% 2017.4.6
clear;close all;clc;tic

%%  input

NEEy_pt = '/home/test2/MTE_NEE/NEE_new02/ytotal';
hds = 'NEEgra_FluxSum_';
fts = '_01to12_total.tif';
[efrg1,efrg2] = deal(-5000,10000);
sf = 1;
[yr1,yr2] = deal(1982,2011);

pynum_fl = '/home/test2/MTE_NEE/NEE_new02/PsNg_year/NEEgra_1982to2011_psYnum.tif';
nynum_fl = '/home/test2/MTE_NEE/NEE_new02/PsNg_year/NEEgra_1982to2011_ngYnum.tif';

outtxt = '/home/test2/MTE_NEE/NEE_new02/PsNg_year/NEE_YrTotalALLpnng.txt';

%%  operate

pynm = double(imread(pynum_fl));
pynm(pynm==pynm(1,1))=nan;
nynm = double(imread(nynum_fl));
nynm(nynm==nynm(1,1))=nan;

idx1 = find(pynm==30);
idx2 = find(nynm==30);
idx3 = find(nynm==30|pynm==30);

rst = nan(yr2-yr1+1,3);
for yr = yr1:yr2
    disp(num2str(yr))
    tmp = double(imread([NEEy_pt,'/',hds,num2str(yr),fts]));
    tmp(tmp<efrg1|tmp>efrg2) = nan;
    
    rst(yr-yr1+1,1) = nansum(tmp(idx1)*sf);
    rst(yr-yr1+1,2) = nansum(tmp(idx2)*sf);
    rst(yr-yr1+1,3) = nansum(tmp(idx3)*sf);
    
    disp(num2str(yr))
end

dlmwrite(outtxt,rst,'delimiter',' ')

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])

