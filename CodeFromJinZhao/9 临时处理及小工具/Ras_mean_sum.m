% 计算文件夹下多幅栅格数据均值或最大值等
% 输入数据应投影相同、范围一致、行列号相同，格式需为geotiff
% 2015.5.31
clear;clc;close all

%%  user

ras_path = 'E:\ISI-MIP_GPP_Pre_SWrad\Gfdl-esm2m_extract\PRP_yr\fur_VI1km30s';    % 输入数据文件夹
valid = [0,2000];    % 输入数据有效数值范围
sf = 1; % 输入数据scale factor

stats = 1;    % 统计类型 1.均值 2.总和 3.最大值 4.标准差 5.CV

outbv = -9999; % 输出结果背景值
prefix = 'pr_bced_1960_1999_gfdl-esm2m_rcp8p5_2030s_LPsqr';  % 结果数据前缀
outpath = 'E:\ISI-MIP_GPP_Pre_SWrad\Gfdl-esm2m_extract\PRP_yr\fur_VI1km30s_mean'; % 结果文件夹

%%  calculate

fs = dir([ras_path,'\*.tif']);

Ginfo = geotiffinfo([ras_path,'\',fs(1).name]);

rtmp = nan(Ginfo.Height, Ginfo.Width, length(fs));
for i = 1:length(fs)
    temp = double(imread([ras_path,'\',fs(i).name]));
    temp(temp<valid(1) | temp>valid(2)) = nan;
    rtmp(:,:,i) = temp*sf;
    clc
    disp('Reading...')
    disp([num2str(i*100/length(fs)),'%'])
end

switch stats
    case 1
        rst = nanmean(rtmp,3);
    case 2
        rst = sum(rtmp,3);
    case 3
        rst = nanmax(rtmp,[],3);
    case 4
        % rst = std(rtmp,0,3,'omitnan');
        rst = nanstd(rtmp,0,3);
    case 5
        % rst = std(rtmp,0,3,'omitnan')./nanmean(rtmp,3);
        rst = nanstd(rtmp,0,3)./nanmean(rtmp,3);
    otherwise
        errordlg('无效统计方法！','stats错误')
end
suffix = {'mean','sum','max','std','CV'};

rst(sum(~isnan(rtmp),3)==0) = nan;
rst(isnan(rst)) = outbv;
geotiffwrite([outpath,'\',prefix,'_',suffix{stats},'.tif'],single(rst),...
    Ginfo.RefMatrix,'GeoKeyDirectoryTag',Ginfo.GeoTIFFTags.GeoKeyDirectoryTag)

disp('Finish!')
