% output Years sum NEE (Unit=g c/m2/year) flux
% Linux
% 2019.10.4
% JiQiulei thrillerlemon@outlook.com
clear;clc

%%  input   –ﬁ∏ƒ’‚¿Ô
yearSE=[1982,2011];

NEEDataPath='/home/JiQiulei/MTE_JQL_2019/NEE_Upscale_Sum2Year';

outputPath='/home/JiQiulei/MTE_JQL_2019/NEE_Sta/';

%%  operate
gridSizze=1/12;
nrows = 1752;
ncols = 4320;
lats = [-56,90];
lons = [-180,180];
Rmat = makerefmat('RasterSize',[nrows,ncols],...
    'Latlim',[lats(1) lats(2)], 'Lonlim',[lons(1) lons(2)],...
    'ColumnsStartFrom','north');

grassNEE = NaN(1752,4320,yearSE(1)-yearSE(2)+1);
for y = yearSE(1):yearSE(2)
    yearNEE=imread([NEEDataPath,'/',num2str(y),'NEEsum2Year_flux.tif']);
    yearNEE(yearNEE==yearNEE(1,1)) = nan;
    grassNEE(:,:,y-yearSE(1)+1)=yearNEE;
end
YearsMean=nanmean(grassNEE,3);
YearsMean(isnan(YearsMean)) = -9999; 
geotiffwrite([outputPath,'YearsMean',num2str(yearSE(1)),'-',num2str(yearSE(2)),'NEEsum2Year_flux.tif'],YearsMean,Rmat);

disp('Finish!')
