% Extract yearly GPP at the positions of all grass sites.
% Windows 10 1903
% 2019.9.11
% JiQiulei thrillerlemon@outlook.com
clear;close all;clc

%%  input
VAR_pt = 'C:\\Users\\thril\\Desktop\\MTEtest';
%文件头
hdn = 'hybrid_gfdl-esm2m_co2_gpp_';
%文件尾
fts = '.tif';
%栅格像元的大小
rsize = 1/2;
%站点的经纬度信息
gra_st_fl = 'C:\\Users\\thril\\Desktop\\MTEtest\\Gra_LatLon.txt';
outfl = 'C:\\Users\\thril\\Desktop\\MTEtest\\Extensive_GPPyearly.txt';

%%  operate
yrs = [2006,2010];
mns = [1,12];

grarc = dlmread(gra_st_fl);
lats = grarc(:,2);
lons = grarc(:,3);
%建立存放结果的矩阵
rst = nan((yrs(2)-yrs(1)+1)*(mns(2)-mns(1)+1),length(lats));
%月份的计数器
mct = 1;

for yr = yrs(1):yrs(2)
    disp(num2str(yr))
    VARm = double(imread([VAR_pt,'\\',hdn,num2str(yr),fts]));
    %设置背景值
    VARm(VARm==VARm(1,1)) = nan;
    %循环12个月
    for mn = mns(1):mns(2)
        %循环44个站点
        for ist = 1:length(lats)
            %获取对应经纬度的值，以度为标准以行列读取世界地图中的值
            rst(mct,ist) = VARm(ceil((90-lats(ist))/rsize),...
                ceil((lons(ist)+180)/rsize));  % VAR
        end
        mct = mct+1;
    end
end

ym = [kron((yrs(1):yrs(2))',ones(mns(2)-mns(1)+1,1)),...
    repmat((mns(1):mns(2))',yrs(2)-yrs(1)+1,1)];

dlmwrite(outfl,[ym,rst])
disp('Finish!')