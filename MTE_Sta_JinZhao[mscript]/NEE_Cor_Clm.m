% Mean of global and regional correlation coefficient between NEE and PRP, TEM, SWR and GMIF.
% geotiff
% 2017.4.3
clear;close all;clc;tic

%%  Input

NEEcor_pt = '/home/test2/MTE_NEE/NEE_year/CorSens';
clmgs_fl = '/home/test2/MTE_NEE/OtherData/Gras_Clim.tif';  % climate of grassland

%%  Operate

cornms = {'PRP','TEM','SWR','GMIF'};

disp('clm')
clmgs = double(imread(clmgs_fl));
clmgs(clmgs==clmgs(1,1)) = nan;
clmgs2 = clmgs(:);
clmgs2(isnan(clmgs2)) = [];
uqclm = unique(clmgs2(:));
clmidx = cell(length(uqclm)+1,1);
for clm = 1:length(uqclm)
    clmidx{clm} = find(clmgs==uqclm(clm));
end
clmidx{length(uqclm)+1} = find(~isnan(clmgs));
clearvars clmgs clmgs2

vrcors = nan(4,length(clmidx),2);
disp('start')
for vr = 1:4
    vrcr = double(imread([NEEcor_pt,'/NEEgra_',cornms{vr},'_Cor.tif']));
    vrcr(vrcr==vrcr(1,1)) = nan;
    
    for clm = 1:length(clmidx)
        vrcors(vr,clm,1) = nanmean(vrcr(clmidx{clm}));
        vrcors(vr,clm,2) = nanstd(vrcr(clmidx{clm}));
    end
    disp(cornms{vr})
end

disp('write')
dlmwrite([NEEcor_pt,'/NEE_CorMean_zone.txt'],...
    [[uqclm',9999];vrcors(:,:,1)],'delimiter',' ')
dlmwrite([NEEcor_pt,'/NEE_CorSTD_zone.txt'],...
    [[uqclm',9999];vrcors(:,:,2)],'delimiter',' ')

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])

