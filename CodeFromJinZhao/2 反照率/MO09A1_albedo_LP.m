%  MOD09A1 7波段计算albedo
%  参数参考Liang 1999 "Retrieval of Land Surface Albedo from Satellite Observations: A Simulation Study"
%  MOD09A1数据命名:"MOD09A1.A2001001.h25v04.006.2015140114734.hdf"
clear;close all;clc

%%  Input

mod09_pt = 'H:\MOD09A1\HDF';  % MOD09A1 HDF数据路径
fillvl = -28672;  % fill value
sf = 0.0001;  % scale factor

idxras = 'H:\MOD09A1\refsamp\MO09A1_idx.tif';  % 提取LPfat范围索引raster
refras = 'H:\MOD09A1\refsamp\MO09A1_ref.tif';  % 拼接后LPfatout参考投影raster

bv = -9999;  % 输出背景值
outpt = 'H:\MOD09A1\albedo\org';  % 输出结果目录

%%  Operate

afs = dir([mod09_pt, '\*.hdf']);
anm = {afs.name};
dates = nan(length(anm), 1);
for afn = 1:length(anm)
    dates(afn) = str2double(anm{afn}(10:16));  % yyyyddd
end
dates = unique(dates);
samp = double(imread(idxras));
samp(samp == samp(1,1)) = nan;
[lpr,lpc] = find(~isnan(samp));
lpr = [min(lpr), max(lpr)];
lpc = [min(lpc), max(lpc)];

clearvars afs anm samp

Rinfo = geotiffinfo(refras);
rows = 2400;cols = 2400;  % row col
bdwt = [0.3973,0.2382,0.3489,-0.2655,0.1604,-0.0138,0.0682,0.0036];  % Liang 1999
bdstr = {'sur_refl_b01';'sur_refl_b02';'sur_refl_b03';'sur_refl_b04';...
    'sur_refl_b05';'sur_refl_b06';'sur_refl_b07'};

hvs = {'h25v04', 'h25v05', 'h26v04', 'h26v05', 'h27v05'};  % h:column, v:row
for idt = 1:length(dates)
    
    albds = nan(rows, cols, length(hvs));
    for ihv = 1:length(hvs)
        hdfs = dir([mod09_pt,'\MOD09A1.A',num2str(dates(idt)),'.',hvs{ihv},'*.hdf']);
        
        albedo = zeros(rows, cols);
        for bd = 1:length(bdstr)
           tmp =  double(hdfread([mod09_pt,'\',hdfs.name], bdstr{bd}));
           tmp(tmp == fillvl) = nan;
           albedo = albedo + tmp*sf*bdwt(bd);
           
           clc
           disp(['Process:',num2str((idt-1)*100/length(dates)),'%'])
           disp(['Date:',num2str(dates(idt))])
           disp(['Tile:',hvs{ihv}])
           disp(['Band:',num2str(bd)])
        end
        albedo = albedo + bdwt(8);
        
        albds(:,:,ihv) = albedo;
    end
    albds(isnan(albds)) = bv;
    
    result = [[albds(:,:,1);albds(:,:,2)], ...
        [albds(:,:,3);albds(:,:,4)],...
        [bv*ones(rows,cols);albds(:,:,5)]];
    outras = result(lpr(1):lpr(2), lpc(1):lpc(2)); 
    
    geotiffwrite([outpt,'\MOD09A1.A',num2str(dates(idt)),'.tif'], outras, ...
        Rinfo.RefMatrix, 'GeoKeyDirectoryTag', Rinfo.GeoTIFFTags.GeoKeyDirectoryTag)
end

disp('Finish!')
