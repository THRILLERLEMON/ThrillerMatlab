%  Month to Year Raster
%  geotiff
% JZ 2018.1.28
clear;clc;close all

%%  user
raspt = 'D:\GIMMS_NDVI\mvc_NDVI_world_fc';  % Monthly rasters'document

hds = '';  % �ļ�������ǰ�ַ���
fts = '_fc.tif';  % �ļ������º��ַ���
vd = [0,100];  % valid value
sf = 1;  % scale factor

ygap = [1982,2013];  % years
mgap = [4,10];  % �����·�

stats = 1;  % ���㷽ʽ 1����ֵ 2�����ֵ 3����Сֵ 4�����ֵ-��Сֵ 5���ܺ�

bv = -99;  % ������ݱ���ֵ
outpt = 'D:\GIMMS_NDVI\mvc_NDVI_world_fc_gr4to10';  % Result year rasters'document

%%  calculate

disp('Year Data')
for yr = ygap(1):ygap(2)
    m_ras = [];
    Ginfo = geotiffinfo([raspt,'\',hds,num2str(yr),num2str(mgap(1),'%02d'),fts]);
    Rmat = Ginfo.RefMatrix;
    Rtag = Ginfo.GeoTIFFTags.GeoKeyDirectoryTag;
    for mon = mgap(1):mgap(2)
        fl = [raspt,'\',hds,num2str(yr),num2str(mon,'%02d'),fts];
        if exist(fl,'file')
            tmp = double(imread(fl));
            tmp(tmp<vd(1) | tmp>vd(2)) = nan;
            tmp = tmp*sf;
            m_ras = cat(3,m_ras,tmp);
        end
    end
    switch stats
        case 1
            rst = nanmean(m_ras,3);
            suffix = '_ave_';
        case 2
            rst = max(m_ras,[],3);
            suffix = '_max_';
        case 3
            rst = min(m_ras,[],3);
            suffix = '_min_';
        case 4
            rst = max(m_ras,[],3)-min(m_ras,[],3);
            suffix = '_min-max_';
        case 5
            rst = nansum(m_ras,3);
            suffix = '_sum_';
    end
    
    reidx = sum(~isnan(m_ras),3);
    rst(reidx==0) = nan;
    rst(isnan(rst)) = bv;
    geotiffwrite([outpt,'\',hds,num2str(yr),suffix,fts],single(rst),...
        Rmat,'GeoKeyDirectoryTag',Rtag)
    disp(num2str(yr))
end
disp('OK!')
