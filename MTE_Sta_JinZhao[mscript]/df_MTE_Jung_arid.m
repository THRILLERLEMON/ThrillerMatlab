% Mean of differences between MTE and Jung's NEE(ANN, MARS, RF) at Arid.
% geotiff
% 2017.5.8
clear;close all;clc

%%  input

NEEdf_pt = '/home/test2/MTE_NEE/NEE_new02/AnnualMeanDiff';
clm_fl = '/home/test2/MTE_NEE/OtherData/Gras_Clim.tif';

%%  operate

clm = imread(clm_fl);
idx = find(clm==2);  % arid

rst = nan(3,2);

ANNdf = double(imread([NEEdf_pt,'/MTEdf_ANN_82to11.tif']));
ANNdf(ANNdf==ANNdf(1,1)) = nan;
ANNdf = ANNdf(idx);
rst(1,1) = nanmean(ANNdf);
rst(1,2) = nanstd(ANNdf);

MARSdf = double(imread([NEEdf_pt,'/MTEdf_MARS_82to11.tif']));
MARSdf(MARSdf==MARSdf(1,1)) = nan;
MARSdf = MARSdf(idx);
rst(2,1) = nanmean(MARSdf);
rst(2,2) = nanstd(MARSdf);

RFdf = double(imread([NEEdf_pt,'/MTEdf_RF_82to11.tif']));
RFdf(RFdf==RFdf(1,1)) = nan;
RFdf = RFdf(idx);
rst(3,1) = nanmean(RFdf);
rst(3,2) = nanstd(RFdf);

dlmwrite([NEEdf_pt,'/NEEdf_aridMean.txt'],rst,'delimiter',' ')
disp('Finish!')

