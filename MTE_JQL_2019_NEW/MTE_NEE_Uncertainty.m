% Test the MTE NEE¡®s Uncertainty
% Linux
% 2019.10.4
% JiQiulei thrillerlemon@outlook.com
clear;clc

%%  input

NEEDataPath='/home/JiQiulei/MTE_JQL_2019/NEE_Upscale_Sum2Year/Flux';

outputPath='/home/JiQiulei/MTE_JQL_2019/NEE_Sta/';

nrows = 1752;
ncols = 4320;
lats = [-56,90];
lons = [-180,180];
Rmat = makerefmat('RasterSize',[nrows,ncols],...
    'Latlim',[lats(1) lats(2)], 'Lonlim',[lons(1) lons(2)],...
    'ColumnsStartFrom','north');

%%  operate
treeData=NaN(1752,4320,16);

idx = zeros(nrows,ncols);

for t = 1:16
    yearData = NaN(1752,4320,30);
    for y = 1982:2011
        
        yearNEE=imread([NEEDataPath,'/','NEEgra_FluxSum_',num2str(y),'_01to12.tif']);
        yearNEE(yearNEE==yearNEE(1,1)) = nan;
        yearData(:,:,y-1982+1)=yearNEE;
    end
    treeData(:,:,t)=nanmean(yearData,3);
    idx = sum(cat(3,idx,~isnan(yearData)),3);
end

meanAllMT=nanmean(treeData,3);
stdAllMT=nanstd(treeData,0,3);
cvAllMT=stdAllMT./meanAllMT;

meanAllMT(idx==0) = -9999;
stdAllMT(idx==0) = -9999;
cvAllMT(idx==0) = -9999;

geotiffwrite([outputPath,'YearlyMeanAllMT.tif'],meanAllMT,Rmat)
geotiffwrite([outputPath,'YearlyStdAllMT.tif'],stdAllMT,Rmat)
geotiffwrite([outputPath,'YearlyCVAllMT.tif'],cvAllMT,Rmat)

newstdAllMT=stdAllMT*1e15;
newcvAllMT=cvAllMT*1e15;
newstdAllMT(idx==0) = -9999; 
newcvAllMT(idx==0) = -9999; 

geotiffwrite([outputPath,'YearlyStdAllMTe15.tif'],newstdAllMT,Rmat)
geotiffwrite([outputPath,'YearlyCVAllMTe15.tif'],newcvAllMT,Rmat)

% save([outputPath,'Uncertainty'])

disp('Finish!')
