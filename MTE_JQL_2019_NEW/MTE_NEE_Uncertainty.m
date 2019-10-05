% Test the MTE NEE¡®s Uncertainty
% Linux
% 2019.10.4
% JiQiulei thrillerlemon@outlook.com
clear;clc

%%  input

NEEDataPath='/home/JiQiulei/MTE_JQL_2019/NEE_Upscale_Sum2Year';

outputPath='/home/JiQiulei/MTE_JQL_2019/NEE_Sta/';

%%  operate
treeData=NaN(1752,4320,16);
for t = 1:16
    yearData = NaN(1752,4320,30);
    for y = 1982:2011
        yearNEE=imread([NEEDataPath,'/',num2str(y),'NEEsum2Year_flux.tif']);
        yearNEE(yearNEE==yearNEE(1,1)) = nan;
        yearData(:,:,y-1982+1)=yearNEE;
    end
    treeData(:,:,t)=nanmean(yearData,3);
end

meanAllMT=nanmean(treeData,3);
stdAllMT=nanstd(treeData,3);
cvAllMT=stdAllMT./meanAllMT;

meanAllMT(isnan(meanAllMT)) = -9999; 
stdAllMT(isnan(stdAllMT)) = -9999; 
cvAllMT(isnan(cvAllMT)) = -9999; 


nrows = 1752;
ncols = 4320;
lats = [-56,90];
lons = [-180,180];


Rmat = makerefmat('RasterSize',[nrows,ncols],...
    'Latlim',[lats(1) lats(2)], 'Lonlim',[lons(1) lons(2)],...
    'ColumnsStartFrom','north');

geotiffwrite([outputPath,'YearlyMeanAllMT.tif'],meanAllMT,Rmat)
geotiffwrite([outputPath,'YearlyStdAllMT.tif'],stdAllMT,Rmat)
geotiffwrite([outputPath,'YearlyCVAllMT.tif'],cvAllMT,Rmat)


disp('Finish!')
