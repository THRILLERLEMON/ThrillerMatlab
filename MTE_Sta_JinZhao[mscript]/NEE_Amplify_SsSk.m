clear;close all;clc

%%  input

NEEslp_fl = '/home/test2/MTE_NEE/NEE_new02/slp/NEEgraFlx_82to11_slope.tif';
NEEslpsg_fl = '/home/test2/MTE_NEE/NEE_new02/slp/NEEgraFlx_82to11_slp_sig.tif';

pynum_fl = '/home/test2/MTE_NEE/NEE_new02/PsNg_year/NEEgra_1982to2011_psYnum.tif';
nynum_fl = '/home/test2/MTE_NEE/NEE_new02/PsNg_year/NEEgra_1982to2011_ngYnum.tif';

outpt = '/home/test2/MTE_NEE/NEE_new02/slp';

%%  operate

[nrw,ncl] = deal(1752,4320);
Rmat = makerefmat('RasterSize',[nrw ncl],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

NEEslp = double(imread(NEEslp_fl));
NEEslp(NEEslp==NEEslp(1,1))=nan;
NEEslpsg = double(imread(NEEslpsg_fl));
NEEslpsg(NEEslpsg==NEEslpsg(1,1))=nan;

pynm = double(imread(pynum_fl));
pynm(pynm==pynm(1,1))=nan;
nynm = double(imread(nynum_fl));
nynm(nynm==nynm(1,1))=nan;

idx = find(~((NEEslp>0 & pynm==30)|(NEEslp<0 & nynm==30)));
clearvars pynm nynm

NEEslp(idx) = nan;
NEEslpsg(idx) = nan;

NEEslp(isnan(NEEslp)) = -9999;
NEEslpsg(isnan(NEEslpsg)) = -9999;

geotiffwrite([outpt,'/NEE30AmpSlp.tif'],single(NEEslp),Rmat)
geotiffwrite([outpt,'/NEE30AmpSlpsig.tif'],single(NEEslpsg),Rmat)

disp('Finish!')

