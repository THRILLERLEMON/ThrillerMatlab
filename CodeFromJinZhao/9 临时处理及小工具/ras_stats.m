% 统计每幅栅格数据
% geotiff
% 2016.8.7
clear;close all;clc

%%  Input

ras_pt = 'E:\VI_AVHRR34\VI_AVH01\LP_out\ETa';  % 栅格数据目录
efrg = [0,20000];  % effective value's range
sf = 1;  % scale factor

% msk_fl = 'D:\Franz\黄河流域灌区\tif\LPirri.tif';
msk_fl = 'E:\SWATdata\HRU\LPmsk\VI_LP_msk.tif';
% msk_fl = 'E:\SWATdata\HRU\ras\YR_hru_VI1km_LP.tif';
msk_vd = [0,2000];

fstat = 1;  % 1:均值 2:最大值 3:最小值 4:标准差 5:5%分位数 6:95%分位数

stnm = 'ETa_VI';  % 结果xls文件sheet名
outxls = 'E:\SWATdata\HRU\VI_LP.xlsx';  % 结果xls文件

%%  Operate

switch fstat
    case 1
        funsts = @(x)mean(x);
        stadd='mean';
    case 2
        funsts = @(x)max(x);
        stadd='max';
    case 3
        funsts = @(x)min(x);
        stadd='min';
    case 4
        funsts = @(x)std(x);
        stadd='std';
    case 5
        funsts = @(x)prctile(x,5);
        stadd='5per';
    case 6
        funsts = @(x)prctile(x,95);
        stadd='95per';
end

if ~isempty(msk_fl)
   msk = double(imread(msk_fl));
   msk(msk<msk_vd(1)|msk>msk_vd(2)) = nan;
end

afs = dir([ras_pt,'\*.tif']);
rst = nan(length(afs),1);
for fl = 1:length(afs)
    tmp=double(imread([ras_pt,'\',afs(fl).name]));
    tmp(tmp<efrg(1) | tmp>efrg(2)) = nan;
    if exist('msk','var')
        tmp(isnan(msk)) = nan;
    end
    tmp=tmp(:)*sf;
    tmp(isnan(tmp))=[];
    rst(fl)=funsts(tmp);
    
    clc
    fprintf(['%s\n%-',num2str(length(stadd)),'s%s%6.2f%s\n'],...
        stnm,stadd,':',fl*100/length(afs),'%')
end

warning off MATLAB:xlswrite:AddSheet
xlswrite(outxls,{afs.name}',[stnm,'_',stadd],'a1')
xlswrite(outxls,rst,[stnm,'_',stadd],'b1')

disp('Finish!')
