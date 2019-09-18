% Extract yearly Manure_Application data from MTE and Jung at the positions of all grass sites.
% Windows 10 1903
% 2019.9.16
% JiQiulei thrillerlemon@outlook.com
clear;close all;clc

%%  input
yrs = [1982,2011];
mns = [1,12];
%栅格像元的大小
rsize=1/12;
%站点的经纬度信息
gra_st_fl = 'E:\OFFICE\MTE_NEE_DATA\Gra_LatLon.txt';
outpt = 'E:\OFFICE\MTE_NEE_DATA\GraSitData';

VARm = double(imread('E:\OFFICE\MTE_NEE_DATA\DEM_Data\vbf_MERIT_10km.tif'));
VARm(VARm==VARm(1,1)) = nan;

%%  operate
grarc = dlmread(gra_st_fl);
lats = grarc(:,2);
lons = grarc(:,3);
%建立存放结果的矩阵
rst = nan((yrs(2)-yrs(1)+1)*(mns(2)-mns(1)+1),length(lats));
%月份的计数器
mct = 1;
for yr = yrs(1):yrs(2)
    for mn = mns(1):mns(2)
        for ist = 1:length(lats)
            rst(mct,ist) = VARm(ceil((90-lats(ist))/rsize),...
                ceil((lons(ist)+180)/rsize));  % MTE
        end
        mct = mct+1;
    end
    disp(num2str(yr))
end

ym = [kron((yrs(1):yrs(2))',ones(mns(2)-mns(1)+1,1)),...
    repmat((mns(1):mns(2))',yrs(2)-yrs(1)+1,1)];
dlmwrite([outpt,'\vbf_SiteMonthly.txt'],...
    [ym,rst])

disp('Finish!')