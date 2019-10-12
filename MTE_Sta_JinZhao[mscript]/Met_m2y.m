% Month to Year Raster
% geotiff
% 2017.5.2
clear;clc;close all

%%  user
monpt = '/home/LiShuai/Data/Long_Radiation_month/day_sum';

hds = '';  
fts = '_Long_Wave_Radiation.tif';  
efrg = [-5000,100000];  % 
sf = 1;  % 

m = 360;

yrs = [1982,2011];  % years
mns = [1,12];  %

stats = 1;  % 1 mean 2 max 3 min 4 max-min 5 sum

bv = -9999;  % 
outpt = '/home/test2/MTE_NEE/MeteoData/LongRad/yall';  % Result year rasters'document

%%  calculate

[nrw,ncl] = deal(1752,4320);
Rmat = makerefmat('RasterSize',[nrw ncl],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

disp('Year Data')
for yr = yrs(1):yrs(2)
    m_ras = [];
    for mon = mns(1):mns(2)
        fl = [monpt,'/',hds,num2str(yr),num2str(mon,'%02d'),fts];
        if exist(fl,'file')
            data = double(imread(fl));
            data(data<efrg(1) | data>efrg(2)) = nan;
            data = data*sf;
            m_ras = cat(3,m_ras,data);
        end
    end
    switch stats
        case 1
            rst = nanmean(m_ras,3);
            suffix = '_ave_';
        case 2
            rst = max(m_ras,[],3);
            suffix = '_max_';
        case 3
            rst = min(m_ras,[],3);
            suffix = '_min_';
        case 4
            rst = max(m_ras,[],3)-min(m_ras,[],3);
            suffix = '_min-max_';
        case 5
            rst = nansum(m_ras,3);
            suffix = '_sum_';
    end
    
    nidx = sum(~isnan(m_ras),3);
    rst(nidx==0)=nan;
    if m==360
       rst = kron(rst,ones(6,6)); 
    end
    rst = rst(1:1752,:);
    
    rst(isnan(rst)) = bv;
    geotiffwrite([outpt,'/',hds,num2str(yr),suffix,fts],single(rst),Rmat)
    disp(num2str(yr))
end
disp('OK!')
