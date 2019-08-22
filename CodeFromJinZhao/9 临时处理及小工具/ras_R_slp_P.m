% 计算栅格数据R2、Slope、F值、P值及显著的slope值
% 输入数据为geotiff，范围一致且行列数相同
% JZ 2017.3.27
tic
clear;clc;close all;

%%  user

ras_path = 'D:\Franz\ETinversGPP\ET_PRP_gaps\PRP_GIDS\MnEle65Neg30stSmth2_crct_VerticalZonal_82to12Yr\PRPmnsET';    %栅格数据存储路径
valid = [-1000,1000];    %输入数据有效值范围
sf = 1;  %scale factor

psig = 0.05;  % P值显著性水平

outpath = 'D:\Franz\ETinversGPP\ET_PRP_gaps\PRP_GIDS\MnEle65Neg30stSmth2_crct_VerticalZonal\PRPmnsET_slp\org'; %结果存储路径
prefix = 'VI_ETmnsPRP_1982to2012_PRP_crct';   %输出数据前缀
bvalue = -9999;  %输出数据背景值

%%  calculate

fs = dir([ras_path,filesep,'*.tif']);
fns = {fs(:).name};

Ginfo = geotiffinfo([ras_path,filesep,fns{1}]);
Rmat = Ginfo.RefMatrix;
Rtag = Ginfo.GeoTIFFTags.GeoKeyDirectoryTag;

data = nan(Ginfo.Height, Ginfo.Width, length(fns));

disp('Reading...')
for fl = 1:length(fns)
    dtmp = imread([ras_path,filesep,fns{fl}]);
    dtmp = double(dtmp);
    dtmp(dtmp<valid(1) | dtmp>valid(2)) = nan;  % valid
    data(:,:,fl) = dtmp*sf;
end

[s1,s2,s3] = size(data);
ras_stats = nan(s1,s2,5); %slpe r2 f p slope_sig
for ir = 1:s1
    for ic = 1:s2
        tmp = squeeze(data(ir,ic,:));
        tmp(isnan(tmp)) = [];
        if length(tmp)>=s3*0.9 && length(unique(tmp))>1
            [b,~,~,~,stats] = regress(tmp,[ones(length(tmp),1),(1:length(tmp))']);
            %if b(2) ~= 0  %有效范围内出现的无效数据
            ras_stats(ir,ic,1) = b(2);  % slope
            if stats(3) < psig
                ras_stats(ir,ic,5) = b(2);  % slope sig
            end
            %end
            ras_stats(ir,ic,2) = stats(1);  % R2
            ras_stats(ir,ic,3) = stats(2);  % F
            ras_stats(ir,ic,4) = stats(3);  % P
        end
    end
    clc
    disp('Linear regress')
    disp(['process:',num2str(ir*100/s1),'%'])
end
ras_stats(isnan(ras_stats)) = bvalue;

%%  write

var = {'slope','r2','F','P','slp_sig'};
for m = 1:5
    geotiffwrite([outpath,filesep,prefix,'_',var{m},'.tif'],...
        single(ras_stats(:,:,m)),Rmat,'GeoKeyDirectoryTag',Rtag)
    disp(var{m})
end
mins = toc;
disp(['完成，共用时',num2str(mins/60),'分钟'])
