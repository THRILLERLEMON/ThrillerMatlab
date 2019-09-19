% extent tiff to Global
% Windows10 1903
% 2019.9.19
% JiQiulei thrillerlemon@outlook.com
clear;close all;clc

%%  input
var1pt='E:\OFFICE\MTE_NEE_DATA\NHx_N_Deposition1982_2011';
var2pt='E:\OFFICE\MTE_NEE_DATA\NOy_N_Deposition1982_2011';
var1hd='NHx_N_Deposition_';
var2hd='NOy_N_Deposition_';
yrs = [1982,2011];
outpt='E:\OFFICE\MTE_NEE_DATA\N_Deposition1982_2011'


Rmat = makerefmat('RasterSize',[360,720],...
    'Latlim',[-90 90], 'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

for yr = yrs(1):yrs(2)
    var1=double(imread([var1pt,'\',var1hd,num2str(yr),'.tif']));
    var2=double(imread([var2pt,'\',var2hd,num2str(yr),'.tif']));
    var1(var1==-9999) = NaN;
    var2(var2==-9999) = NaN;
    bothVar=var1+var2;
    bothVar(isnan(bothVar)) = -9999;
    geotiffwrite([outpt,'\','N_Deposition','_',num2str(yr),'.tif'],bothVar,Rmat)
    disp(num2str(yr))
end

disp('Finish!')
