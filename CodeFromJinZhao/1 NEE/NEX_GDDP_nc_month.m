%��ȡNEX_GDDPȫ��NC�����ݣ�����������
%NEX_GDDP����Ϊÿ��һ��NC���ݣ�ÿ��NC���ݴ洢����ÿ������
%����ϵΪ��������ϵ
tic
clear all;close all;clc

%%  user

%��������ע�⣺�����ݵ�λ���㷽����Ҫ������������޸�
ncpath = 'H:\NEX_GDDP\NC����\pr_day_BCSD_historical_CNRM-CM5';  % NC���ݴ洢Ŀ¼
tnum = 7;  %    �ļ����������ʼλ�ã���ĩβ����λ����
varname = 'pr'; %   ��Ҫ��ȡ�ı�����
unit_sf = 24 * 60 * 60; %��λת��

prefix = 'pr_historical_CNRM-CM5_';  %  �������ǰ׺
outbv = -99999;  %  ����������ֵ
outpath = 'H:\NEX_GDDP\GeoTIFF����\pr_month_BCSD_historical_CNRM-CM5'; %  ���·��

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
        vtmp = nansum(vtmp, 3) * unit_sf;   %������������λת��,��ˮԭʼ��λ��kg m-2 s-1��kg m-2��mm m-2����ֵ�ϵ�Ч
        vtmp(isnan(vtmp)) = outbv;
        vtmp = fliplr(rot90(vtmp, -1));
        
        result = [vtmp(:, size(vtmp,2) / 2 + 1:end), vtmp(:, 1:size(vtmp, 2) / 2)];
        geotiffwrite([outpath, '\', prefix, fs(i).name(end - tnum + 1:end - tnum + 4), num2str(mon, '%02d'), '.tif'], result, R)
        disp(num2str(mon))
    end
end
toc
minuts = toc / 60;
disp(['��ɣ�����ʱ', num2str(minuts), '����'])
