% Windows 10 1903
% 2017.3.28
clear;close all;clc;tic

%%  input

psNumPt = 'E:\OFFICE\MTE_NEE_DATA\RunResult\Sta_NEE\NEEgra_1982to2011_psYnum.tif';

ngNumPt = 'E:\OFFICE\MTE_NEE_DATA\RunResult\Sta_NEE\NEEgra_1982to2011_ngYnum.tif';
Data_vd = [-50,50];

pstmp = double(imread(psNumPt));
pstmp(pstmp<Data_vd(1) | pstmp>Data_vd(2)) = nan;
ngtmp = double(imread(ngNumPt));
ngtmp(ngtmp<Data_vd(1) | ngtmp>Data_vd(2)) = nan;

outpt = 'E:\OFFICE\MTE_NEE_DATA\RunResult\Sta_NEE';

[nrw,ncl] = deal(1752,4320);
Rmat = makerefmat('RasterSize',[nrw ncl],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

AreaPic = zeros(nrw,ncl);
pstmp(pstmp~=30)=0;
ngtmp(ngtmp~=30)=0;
ngtmp(ngtmp==30)=-30;
AreaPic=pstmp+ngtmp;

AreaPic(AreaPic==0) = -128;

geotiffwrite([outpt,'\PsNg30Area.tif'],int8(AreaPic),Rmat);
disp('ok!')




