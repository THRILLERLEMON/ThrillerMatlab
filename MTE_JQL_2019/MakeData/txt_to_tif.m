% Translate txt to tiff
% Windows 10 1903
% 2019.9.11
% JiQiulei thrillerlemon@outlook.com
close all;clear;clc

yrs = [1998,2006];
inpt='E:\OFFICE\MTE_NEE_DATA\1860年至2014年期间在农田和牧场中施用粪肥和氮肥\ManNitProCrpRd';
outpt='E:\OFFICE\MTE_NEE_DATA\1860年至2014年期间在农田和牧场中施用粪肥和氮肥\ManNitProCrpRd_TIFF';
fhead='yy';
ftail='.txt';

for yr=yrs(1):yrs(2)
    H=importdata([inpt,'\',fhead,num2str(yr),ftail],' ');
%     cellarry=struct2cell(H);
    rasddata=H;
%     rasddata=cell2mat(cellarry(1,1));
%     rasinfocell=cellarry(2,1);
%     rasinfo=rasinfocell{1};

    lats=[-88.5,88.5];
    lons=[-180,180];
    [nrows,ncols]=size(rasddata);
    Rmat = makerefmat('RasterSize',[nrows,ncols],...
        'Latlim',[lats(1) lats(2)], 'Lonlim',[lons(1) lons(2)],...
        'ColumnsStartFrom','north');
    geotiffwrite([outpt,'\',fhead,num2str(yr),'.tif'], rasddata,Rmat);
end

disp('Finish!')