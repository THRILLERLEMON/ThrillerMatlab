% 根据指定经纬度范围提取GIMMS NDVI半月数据
% 2018.4.3
close all;clear;clc

%%  input

GNDVI_nc_pt = 'G:\GIMMS_NDVI3g\NC4';
hd = 'ndvi3g_geo_v1_';
vrnm = 'ndvi';
vd = [0,10000];
sf = 1;

[yr1,yr2] = deal(1981,1981);
[mn1,mn2] = deal(7,12);

lonlms = [100.819,114.577];
latlms = [33.633,41.373];
znstr = 'LP';

bv = -99;
outpt = 'G:\GIMMS_NDVI3g\LPsqr_int2';

%%  operate

if ~exist(outpt,'dir')
    mkdir(outpt)
end

af1 = dir([GNDVI_nc_pt,filesep,'*.nc4']);
af1 = [GNDVI_nc_pt,filesep,af1(1).name];
nlon=ncinfo(af1,'lon'); nlon = nlon.Size;
nlat=ncinfo(af1,'lat'); nlat = nlat.Size;

col1 = max([1,ceil((lonlms(1)+180)/(360/nlon))]);
col2 = ceil((lonlms(2)+180)/(360/nlon));
cols = col2-col1+1;
row1 = max([1,ceil(-(latlms(2)-90)/(180/nlat))]);
row2 = ceil(-(latlms(1)-90)/(180/nlat));
rows = row2-row1+1;

Rmat = makerefmat('RasterSize',[rows,cols],...
    'Latlim',[90-row2*180/nlat,90-(row1-1)*180/nlat],...
    'Lonlim',[-180+(col1-1)*360/nlon,-180+col2*360/nlon],...
    'ColumnsStartFrom','north');

hfmon = {'a','b'};

for yr = yr1:yr2
    for mn = mn1:mn2
        if mn<=6
            mnstr = '0106';
            mnfst = 1;
        else
            mnstr = '0712';
            mnfst = 7;
        end
        fl = dir([GNDVI_nc_pt,filesep,hd,num2str(yr),'_',mnstr,'.nc4']);
        for x1 = 1:2
            leaf1 = (mn-mnfst)*2+x1;
            tmp = ncread([GNDVI_nc_pt,filesep,fl.name],vrnm,...
                [col1,row1,leaf1],[cols,rows,1],[1,1,1]);
            tmp(tmp<vd(1)|tmp>vd(2)) = nan;
            tmp = tmp'*sf;
            tmp(isnan(tmp)) = bv;
            geotiffwrite([outpt,filesep,hd,num2str(yr),...
                num2str(mn,'%02d'),hfmon{x1},'_',znstr,'.tif'],...
                single(tmp),Rmat)
            
            clc
            disp([num2str(yr),' ',num2str(mn,'%02d'),hfmon{x1}])
        end
    end
end

disp('Finish!')
