% The coefficient of partial correlation between NEE with PRP and TEM.
% geotiff
% 2017.5.13
tic;clear;close all;clc

%%  Input

Frostpt = 'E:\OFFICE\MTE_NEE_DATA\RunResult\StaNEE_Frost_SR_space\Frost_day_frequency_82-11__mean.tif';
SRpt = 'E:\OFFICE\MTE_NEE_DATA\RunResult\StaNEE_Frost_SR_space\MM_short_radiation_sum2Year__sum.tif';
Grasspt='E:\OFFICE\MTE_NEE_DATA\World_Koppen_Map_0.5_reclas5_grass.tif';
outpt = 'E:\OFFICE\MTE_NEE_DATA\RunResult\StaNEE_Frost_SR_space\';  % Outpath

gclm = double(imread(Grasspt));
gclm(gclm==gclm(1,1))=nan;

Forst = double(imread(Frostpt)); 
Forst(Forst==-9999) = nan;
Forst=Forst(1:size(gclm,1),:);
SR = double(imread(SRpt)); 
SR(SR==-9999) = nan;
SR=SR(1:size(gclm,1),:);

GrassForst=Forst(~isnan(gclm));
GrassSR=SR(~isnan(gclm));

ForstPiont=GrassForst(~isnan(GrassForst)&~isnan(GrassSR));
SRPiont=GrassSR(~isnan(GrassForst)&~isnan(GrassSR));


outdata=[ForstPiont(:),SRPiont(:)];

xlswrite([outpt,'RelNEE_PRPbyStep.xlsx'],outdata );

disp('OK!')
