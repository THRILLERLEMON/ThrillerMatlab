% Extract yearly NEE flux data from MTE and Jung at the positions of all grass sites.
% 2017.4.18
clear;close all;clc

%%  input
MTE_NEE_pt = '/home/LiShuai/Data/meanfapar_growseason_year';  % flux
%文件头
hdm = 'meanfapar_growseason_';
%文件尾
ftm = 'year.tif';

yrs = [1982,2011];
%栅格像元的大小
rsize=1/12;

%站点的经纬度信息
gra_st_fl = '/home/test2/MTE_NEE/NEE_new/Data_contrast/GraALL_LatLon.txt';

outpt = '/home/LiShuai/Data';

%%  operate

grarc = dlmread(gra_st_fl);
lats = grarc(:,2);
lons = grarc(:,3);
%建立存放结果的矩阵
rst = nan(yrs(2)-yrs(1)+1,length(lats));
for yr = yrs(1):yrs(2)
    NEEm = double(imread([MTE_NEE_pt,'/',hdm,num2str(yr),ftm]));

    for ist = 1:length(lats)
        rst(yr-yrs(1)+1,ist) = NEEm(ceil((90-lats(ist))/rsize),...
            ceil((lons(ist)+180)/rsize));  % MTE
    end

    disp(num2str(yr))
end

dlmwrite([outpt,'/meanfapar_growseason_year.txt'],...
    [(yrs(1):yrs(2))',rst])

disp('Finish!')