% Calculate the area, grids number and sum of NEE total.
% geotiff
% 2017.5.12
clear;close all;clc

%%  input

IdeRasPt = 'C:\Users\thril\Desktop\80s00s\YearsMean00s-80s.tif';

IdeRas = double(imread(IdeRasPt));
IdeRas(IdeRas==IdeRas(1,1)) = nan;

% wdzone = ones(1752,4320);
Rmat = makerefmat('RasterSize',[1752 4320],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

sigRas=sign(IdeRas);
sigRas(isnan(IdeRas))= -128;

geotiffwrite('C:\Users\thril\Desktop\80s00s\YearsMean00s-80s_Sign.tif',sigRas,Rmat)


disp('Finish!')

