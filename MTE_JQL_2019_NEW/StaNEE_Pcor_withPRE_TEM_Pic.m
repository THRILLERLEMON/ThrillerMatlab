% Windows 10 1903
% 2017.3.28
clear;close all;clc;tic

%%  input

RtemPt = 'C:\Users\thril\Desktop\NEEgraFlxMet2_TEM_pR.tif';

RprpPt = 'C:\Users\thril\Desktop\NEEgraFlxMet2_PRP_pR.tif';
Data_vd = [-5000,50];

Rtem = double(imread(RtemPt));
Rtem(Rtem<Data_vd(1) | Rtem>Data_vd(2)) = nan;
Rprp = double(imread(RprpPt));
Rprp(Rprp<Data_vd(1) | Rprp>Data_vd(2)) = nan;

outpt = 'C:\Users\thril\Desktop';

[nrw,ncl] = deal(1752,4320);
Rmat = makerefmat('RasterSize',[nrw ncl],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');


PminT=abs(Rprp)-abs(Rtem);
PminT_sign=sign(PminT);


PminT_sign(isnan(PminT_sign)) = -128;

geotiffwrite([outpt,'\JZ_PTcontrolArea.tif'],int8(PminT_sign),Rmat);
disp('ok!')




