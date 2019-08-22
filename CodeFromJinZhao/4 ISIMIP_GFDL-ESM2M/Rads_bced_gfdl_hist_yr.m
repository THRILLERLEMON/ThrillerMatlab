% rsds_bced_1960_1999_gfdl-esm2m_hist_1981-1990
% Extract yearly
% LINUX
% 2017.9.27
close all;clear;clc

%%  input

NCpt = 'D:\Gfdl-esm2m\SWrad\His';
NChd = 'rsds_bced_1960_1999_gfdl-esm2m_hist';
yrss = [[1981,1990];[1991,2000];[2001,2005]];

vstr = 'rsdsAdjust';

nrows = 360;
ncols = 720;
lats = [-90,90];
lons = [-180,180];

bv = -9999;
outpt = 'D:\Gfdl-esm2m_extract\SWrad\hist';

%%  operate

mkdir(outpt)
Rmat = makerefmat('RasterSize',[nrows,ncols],...
    'Latlim',[lats(1) lats(2)], 'Lonlim',[lons(1) lons(2)],...
    'ColumnsStartFrom','north');

for x = 1:size(yrss,1)
    NC_fl = [NCpt,'\',NChd,'_',num2str(yrss(x,1)),'-',num2str(yrss(x,2)),'.nc'];
    NCy = yrss(x,1);
    yrs = yrss(x,:);
    
    dysbf = 0;
    for yr = NCy:yrs(1)-1
        ndys = 365;
        if mod(yr,400)==0||(mod(yr,4)==0 && mod(yr,100)~=0)
            ndys = 366;
        end
        dysbf = dysbf+ndys;
    end
    nst = dysbf+1;
    
    for yr = yrs(1):yrs(2)
        ndys = 365;
        if mod(yr,400)==0||(mod(yr,4)==0 && mod(yr,100)~=0)
            ndys = 366;
        end
        
        ytmp = double(ncread(NC_fl,vstr,...
            [1 1 nst],[ncols nrows ndys],[1 1 1]));
        ytmp(ytmp==ytmp(1,1,1)) = nan;
        ytmp(ytmp<0) = 0;
        ytmp = ytmp*1e-6*60*60*24;  % W/m2 --- MJ/m2/day
        
        yidx = sum(~isnan(ytmp),3);
        ytmp = nansum(ytmp,3);
        ytmp(yidx==0) = nan;
        ytmp(isnan(ytmp)) = bv;
        ytmp = ytmp';
        
        nst = nst+ndys;
        geotiffwrite([outpt,'/',NChd,num2str(yr),'.tif'],single(ytmp),Rmat)
        
        disp(num2str(yr))
    end
end
disp('Finish!')
