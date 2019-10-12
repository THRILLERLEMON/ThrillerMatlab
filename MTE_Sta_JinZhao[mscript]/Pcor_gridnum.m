% Calculate the number of grids control factors.
% 2017.4.11
clear;close all;clc

%%  input

pc_fl = '/home/test2/MTE_NEE/NEE_year/Pcor/met_negtive/NEEgraFluxSum_pRmax_min.tif';
pcsig_fl = '/home/test2/MTE_NEE/NEE_year/Pcor/met_negtive/NEEgraFluxSum_pRmax_min_sig.tif';
outpt = '/home/test2/MTE_NEE/NEE_year/Pcor/met_negtive';
scstr = 'met_negtive';

NEEttave_fl = '/home/test2/MTE_NEE/NEE_year/ymean/NEEgra_Total82to11_mean.tif';

%%  operate

NEEtt = double(imread(NEEttave_fl));
NEEtt(NEEtt==NEEtt(1,1)) = nan;

pcr = double(imread(pc_fl));
pcr(pcr == pcr(1,1)) = nan;

pcrsig = double(imread(pcsig_fl));
pcrsig(pcrsig == pcrsig(1,1)) = nan;

pcr1 = pcr(:);
pcr1(isnan(pcr1)) = [];
uqpc = unique(pcr1);

nmrst = nan(2,length(uqpc));
ttrst = nan(2,length(uqpc));
for ifc = 1:length(uqpc)
    idx1 = find(pcr==uqpc(ifc));
    nmrst(1,ifc) = numel(idx1);
    ttrst(1,ifc) = nansum(NEEtt(idx1));
    
    idx2 = find(pcrsig==uqpc(ifc));
    nmrst(2,ifc) = numel(idx2);
    ttrst(2,ifc) = nansum(NEEtt(idx2));
end

dlmwrite([outpt,'/Pcor_num_',scstr,'.txt'],[uqpc';nmrst],'delimiter',' ')
dlmwrite([outpt,'/Pcor_NEEsum_',scstr,'.txt'],[uqpc';ttrst],'delimiter',' ')

disp('Finish!')

