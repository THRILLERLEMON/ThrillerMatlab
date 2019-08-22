%  Day to Year Raster
%  geotiff
clear;clc;close all

%%  user

raspath = 'E:\R\Raster_test\NDVImon';  % 日数据文件夹

heads = '';  % 日数据文件名中年信息前字符串
valid = [0, 10000];  % 有效值范围
sf = 1;  % scale factor

ygap = [1982, 1985];  % 处理年份
stats = 1;  % 计算方式 1：均值 2：最大值 3：最小值 4：最大值-最小值 5：总和

outbv = -9999;  % 输出数据背景值
outpath = 'E:\R\Raster_test\mon2year_result\matlab';  % 结果存储路径

%%  calculate

disp('Year Data')
afs = dir([raspath, '\', heads, '*.tif']);
Rinfo = geotiffinfo([raspath, '\', afs(1).name]);

for years = ygap(1):ygap(2)
    dfs = dir([raspath, '\', heads, num2str(years), '*.tif']);
    if ~isempty(dfs)
        d_ras = [];
        for ids = 1:length(dfs)
            data = double(imread([raspath, '\', dfs(ids).name]));
            data(data < valid(1) | data > valid(2)) = nan;
            data = data * sf;
            d_ras = cat(3, d_ras, data);
        end
        
        switch stats
            case 1
                result = nanmean(d_ras, 3);
                suffix = '_Day_ave';
            case 2
                result = max(d_ras, [], 3);
                suffix = '_Day_max';
            case 3
                result = min(d_ras, [], 3);
                suffix = '_Day_min';
            case 4
                result = max(d_ras, [], 3) - min(d_ras, [], 3);
                suffix = '_Day_man2min';
            case 5
                result = sum(d_ras, 3);
                suffix = '_Day_sum';
        end
        
        result(sum(isnan(d_ras), 3) == size(d_ras, 3)) = nan;
        result(isnan(result)) = outbv;
        geotiffwrite([outpath, '\', heads, num2str(years), suffix, '.tif'], result,...
            Rinfo.RefMatrix, 'GeoKeyDirectoryTag', Rinfo.GeoTIFFTags.GeoKeyDirectoryTag)
        disp(num2str(years))
    end
end
disp('OK!')
