% Translate txt to tiff
% Windows 10 1903
% 2019.9.11
% JiQiulei thrillerlemon@outlook.com
close all;clear;clc

yrs = [1998,2006];
inpt='E:\OFFICE\MTE_NEE_DATA\1860 - 2016���ڼ䣬ȫ��ݵ�ϵͳ�еİ����״��ʺͷ��ϵ�����\manure_application';
outpt='E:\OFFICE\MTE_NEE_DATA\1860 - 2016���ڼ䣬ȫ��ݵ�ϵͳ�еİ����״��ʺͷ��ϵ�����\manure_application_TIFF';
fhead='ma';
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