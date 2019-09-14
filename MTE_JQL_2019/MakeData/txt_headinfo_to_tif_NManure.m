% Translate txt to tiff
% Windows 10 1903
% 2019.9.11
% JiQiulei thrillerlemon@outlook.com
close all;clear;clc

yrs = [1982,2011];
inpt='E:\OFFICE\MTE_NEE_DATA\Backup\1860 - 2016年期间，全球草地系统中的半度网状粪肥和肥料氮输入\Nfertilizer_application';
outpt='E:\OFFICE\MTE_NEE_DATA\Nfertilizer_Application1982_2011';
fhead='nfa';
ftail='.txt';

for yr=yrs(1):yrs(2)
    H=importdata([inpt,'\',fhead,num2str(yr),ftail],' ',6);
    cellarry=struct2cell(H);
    rasddata=cell2mat(cellarry(1,1));
    rasinfocell=cellarry(2,1);
    rasinfo=rasinfocell{1};

    lats=[-88.5,88.5];
    lons=[-180,180];
    [nrows,ncols]=size(rasddata);
    Rmat = makerefmat('RasterSize',[nrows,ncols],...
        'Latlim',[lats(1) lats(2)], 'Lonlim',[lons(1) lons(2)],...
        'ColumnsStartFrom','north');
    geotiffwrite([outpt,'\',fhead,num2str(yr),'.tif'], rasddata,Rmat);
end

disp('Finish!')