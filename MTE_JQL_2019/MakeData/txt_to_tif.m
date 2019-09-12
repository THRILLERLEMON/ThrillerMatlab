% Translate txt to tiff
% Windows 10 1903
% 2019.9.11
% JiQiulei thrillerlemon@outlook.com
close all;clear;clc

H=importdata('C:\Users\thril\Desktop\test\manure_application\ma1860.txt',' ',6);

cellarry=struct2cell(H);
rasddata=cell2mat(cellarry(1,1));
rasinfocell=cellarry(2,1);
rasinfo=rasinfocell{1};

lats=[-88.5,88.5];
lons=[-180,180];
[ncols,nrows]=size(rasddata);
outpt1='C:\Users\thril\Desktop\test\ma1860tiff.tif';

Rmat = makerefmat('RasterSize',[nrows,ncols],...
    'Latlim',[lats(1) lats(2)], 'Lonlim',[lons(1) lons(2)]);
    

geotiffwrite(outpt1, rasddata,Rmat,'CoordRefSysCode', 4326);