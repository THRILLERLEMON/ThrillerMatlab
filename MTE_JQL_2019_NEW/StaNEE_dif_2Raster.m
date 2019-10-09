% geotiff
% 2017.5.5
clear;close all;clc

%%  input   1-2

Ras1Pt = 'C:\Users\thril\Desktop\80s00s\NEEflux_2000-2011_mean.tif';

Ras2Pt = 'C:\Users\thril\Desktop\80s00s\NEEflux_1982-1989_mean.tif';


%%  operate

Rmat = makerefmat('RasterSize',[1752 4320],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

Ras1 = double(imread(Ras1Pt));
Ras1(Ras1==Ras1(1,1)) = nan;

Ras2 = double(imread(Ras2Pt));
Ras2(Ras2==Ras2(1,1)) = nan;

df = Ras1-Ras2;

df(isnan(df)) = -9999;


geotiffwrite('C:\Users\thril\Desktop\80s00s\YearsMean00s-80s.tif',df,Rmat)


disp('Finish!')
