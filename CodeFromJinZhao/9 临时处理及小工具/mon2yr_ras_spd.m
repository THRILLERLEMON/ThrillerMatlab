%  Month to Year Raster
%  geotiff
clear;clc;close all

%%  user
raspt = 'D:\SWATdata\HRU2\HRU_LAI_mon_new';  % Month rasters'document

hds = 'SWATnew_LAI_';  % 文件名年月前部分
fts = '.tif';  % 文件名年月后部分
vd = [0,100];  % valid value
sf = 1;  % scale factor

ygap = [1982,2015];  % years
mgap = [5,9];  % 所需月份

stats = 1;  % 计算方式 1：均值 2：总和

bv = -99;  % 输出数据背景值
outpt = 'D:\SWATdata\HRU2\HRU2_LAI_grw';  % Result year rasters'document

%%  calculate

if ~exit(outpt,'dir')
    mkdir(outpt)
end

disp('Year Data')
for yr = ygap(1):ygap(2)
    fprintf([num2str(yr),':'])
    
    Ginfo = geotiffinfo([raspt,filesep,hds,num2str(yr),num2str(mgap(1),'%02d'),fts]);
    Rmat = Ginfo.RefMatrix;
    Rtag = Ginfo.GeoTIFFTags.GeoKeyDirectoryTag;
    [m,n] = deal(Ginfo.Height,Ginfo.Width);
    
    m_ras = zeros(m,n);
    idxn = zeros(m,n);
    for mon = mgap(1):mgap(2)
        fl = [raspt,filesep,hds,num2str(yr),num2str(mon,'%02d'),fts];
        if exist(fl,'file')
            tmp = double(imread(fl));
            tmp(tmp<vd(1) | tmp>vd(2)) = nan;
            tmp = tmp*sf;
            m_ras = m_ras+tmp;
            idxn = idxn+~isnan(tmp);
            fprintf([' ',num2str(mon)])
        end
    end
    if stats==1
        m_ras = m_ras./idxn;
        suffix = 'mean';
    elseif stats==2
        suffix = 'sum';
    end
    
    m_ras(isnan(m_ras)) = bv;
    geotiffwrite([outpt,filesep,hds,num2str(yr),'_',suffix,'.tif'],...
        single(m_ras),Rmat,'GeoKeyDirectoryTag',Rtag)
    fprintf('\n')
end
disp('OK!')
