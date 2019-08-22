% Extract Jung's annual NEE from NC file as geotiff.
% 2017.4.17
clear;close all;clc

%%  input

NEE_pt = 'G:\Jung_NEE\raw\annual';
hds = 'CRUNCEPv6.MARS.NEE.annual.';

yrs = [1980,2013];

outhds = 'CRUNCEPv6.MARS.NEE.annual.';
outpt = 'G:\Jung_NEE\GEOTIFF\annual\MARS';
bv = -9999;

%%  operate

Rmat = makerefmat('RasterSize',[360 720],...
    'Latlim',[-90 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

for yr = yrs(1):yrs(2)
    if mod(yr,400)==0 || (mod(yr,4)==0 && mod(yr,100)~=0)
        ydys = 366;
    else
        ydys = 365;
    end
    
    tmp = ncread([NEE_pt,'\',hds,num2str(yr),'.nc'],'NEE')'*ydys;
    tmp(isnan(tmp)) = bv;
    tmp(end-11:end,:) = bv;  %
    
    geotiffwrite([outpt,'\',outhds,num2str(yr),'.tif'],tmp,Rmat)
    
    disp(num2str(yr))
end

disp('Finish!')
