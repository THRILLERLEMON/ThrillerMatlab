% Test the MTE NEE¡®s Uncertainty
% Linux
% 2019.10.4
% JiQiulei thrillerlemon@outlook.com
clear;clc

%%  input

NEEDataPath='/home/JiQiulei/MTE_JQL_2019/NEE_Upscale';

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

idy = zeros(nrows,ncols);
idt = zeros(nrows,ncols);

for t = 1:16
    yearData = NaN(1752,4320,30);
    for y = 1982:2011
        monthData=NaN(1752,4320,12);
        for m=1:12
            monthNEE=imread([NEEDataPath,'/',num2str(y),num2str(m,'%02d'),'_global_grass_NEE_MT',num2str(t),'.tif']);
            monthNEE(monthNEE==monthNEE(1,1)) = nan;
            monthData(:,:,m)=monthNEE;
            idy = sum(cat(3,idy,~isnan(monthNEE)),3);
        end
        yearNEE=nansum(monthData,3);
        yearNEE(idy==0)=nan;
        yearData(:,:,y-1982+1)=yearNEE;
        idt = sum(cat(3,idt,~isnan(yearNEE)),3);
    end
    treeData(:,:,t)=nanmean(yearData,3);
end

meanAllMT=nanmean(treeData,3);
stdAllMT=nanstd(treeData,0,3);
cvAllMT=stdAllMT./meanAllMT;

meanAllMT(idt==0) = -9999;
stdAllMT(idt==0) = -9999;
cvAllMT(idt==0) = -9999;

geotiffwrite([outputPath,'YearlyMeanAllMT.tif'],meanAllMT,Rmat)
geotiffwrite([outputPath,'YearlyStdAllMT.tif'],stdAllMT,Rmat)
geotiffwrite([outputPath,'YearlyCVAllMT.tif'],cvAllMT,Rmat)

meanAllMT(idt==0) = nan;
stdAllMT(idt==0) = nan;
cvAllMT(idt==0) = nan;

geotiffwrite([outputPath,'YearlyMeanAllMT_NBV.tif'],meanAllMT,Rmat)
geotiffwrite([outputPath,'YearlyStdAllMT_NBV.tif'],stdAllMT,Rmat)
geotiffwrite([outputPath,'YearlyCVAllMT_NBV.tif'],cvAllMT,Rmat)


disp('Finish!')
