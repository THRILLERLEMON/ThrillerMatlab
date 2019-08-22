%读取NEX_GDDP全球NC日数据，计算月数据
%NEX_GDDP数据为每年一个NC数据，每个NC数据存储该年每日数据
%坐标系为地理坐标系
tic
clear all;close all;clc

%%  user

%！！！！注意：月数据单位计算方法需要具体情况具体修改
ncpath = 'H:\NEX_GDDP\NC数据\pr_day_BCSD_historical_CNRM-CM5';  % NC数据存储目录
tnum = 7;  %    文件名中年份起始位置（从末尾倒数位数）
varname = 'pr'; %   需要提取的变量名
unit_sf = 24 * 60 * 60; %单位转换

prefix = 'pr_historical_CNRM-CM5_';  %  输出数据前缀
outbv = -99999;  %  输出结果背景值
outpath = 'H:\NEX_GDDP\GeoTIFF数据\pr_month_BCSD_historical_CNRM-CM5'; %  输出路径

%%  calculate

mon_p = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
mon_r = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

fs = dir([ncpath, '\*.nc']);
for i = 1:length(fs)
    disp(fs(i).name)
    
    vinform = ncinfo([ncpath, '\', fs(i).name], varname);
    dimens = vinform.Size;    % lon lat days
    
    if dimens(3) == 365
        mon_t = mon_p;
    else
        mon_t = mon_r;
    end
    
    R = makerefmat('RasterSize', [dimens(2) dimens(1)], 'Latlim', [-90 90], 'Lonlim', [-180 180]);
    
    for mon = 1:12
        vtmp = double(ncread([ncpath, '\', fs(i).name], varname, [1 1 sum(mon_t(1:mon-1))+1], [inf inf sum(mon_t(mon))]));
        vtmp(vtmp == vinform.FillValue) = nan;
        vtmp = nansum(vtmp, 3) * unit_sf;   %！！！！！单位转换,降水原始单位：kg m-2 s-1。kg m-2与mm m-2在数值上等效
        vtmp(isnan(vtmp)) = outbv;
        vtmp = fliplr(rot90(vtmp, -1));
        
        result = [vtmp(:, size(vtmp,2) / 2 + 1:end), vtmp(:, 1:size(vtmp, 2) / 2)];
        geotiffwrite([outpath, '\', prefix, fs(i).name(end - tnum + 1:end - tnum + 4), num2str(mon, '%02d'), '.tif'], result, R)
        disp(num2str(mon))
    end
end
toc
minuts = toc / 60;
disp(['完成！共用时', num2str(minuts), '分钟'])
