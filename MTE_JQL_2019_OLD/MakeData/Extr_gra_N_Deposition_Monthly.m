% Extract yearly Manure_Application data from MTE and Jung at the positions of all grass sites.
% Windows 10 1903
% 2019.9.16
% JiQiulei thrillerlemon@outlook.com
clear;close all;clc

%%  input
MTE_pt = 'E:\OFFICE\MTE_NEE_DATA\N_Deposition1982_2011';
%文件头
hdm = 'N_Deposition_';
%文件尾
ftm = '.tif';
%年的范围
yrs = [1982,2011];
mns = [1,12];
%栅格像元的大小
rsize=1/2;
%站点的经纬度信息
gra_st_fl = 'E:\OFFICE\MTE_NEE_DATA\Gra_LatLon.txt';
outpt = 'E:\OFFICE\MTE_NEE_DATA\GraSitData';

%%  operate
grarc = dlmread(gra_st_fl);
lats = grarc(:,2);
lons = grarc(:,3);
%建立存放结果的矩阵
rst = nan((yrs(2)-yrs(1)+1)*(mns(2)-mns(1)+1),length(lats));
%月份的计数器
mct = 1;
for yr = yrs(1):yrs(2)
    VARm = double(imread([MTE_pt,'\',hdm,num2str(yr),ftm]));
    VARm(VARm==-9999) = nan;
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
dlmwrite([outpt,'\N_Deposition_SiteMonthly.txt'],...
    [ym,rst])

disp('Finish!')