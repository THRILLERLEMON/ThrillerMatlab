clear;clc

varPath='/home/LiShuai/Data/tem/';

getfilename=ls([varPath,'*.tif']);
filename = strsplit(getfilename)
num_of_files = length(filename)
data = NaN(360,720,num_of_files-1);
for i=1:num_of_files-1
    filsname=filename(i);
    disp(filsname);
    tifDATA=geotiffread(filsname{1});
    tifDATA(tifDATA>999999) = NaN;
    data(:,:,i)=tifDATA;
end
size(data)
datamean=nanmean(data,3);
datamean(isnan(datamean)) = -999; 
nrows = 360;
ncols = 720;
lats = [-90,90];
lons = [-180,180];
Rmat = makerefmat('RasterSize',[nrows,ncols],...
    'Latlim',[lats(1) lats(2)], 'Lonlim',[lons(1) lons(2)],...
    'ColumnsStartFrom','north');
geotiffwrite(['/home/LiShuai/Data/MA_temperature/temyearmean_1982-2013year_meanJQL.tif'],datamean,Rmat);

disp('ok!');


