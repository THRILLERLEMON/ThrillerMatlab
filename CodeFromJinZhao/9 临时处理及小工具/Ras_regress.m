% 计算两个变量栅格尺度上多时间序列数据的线性回归: y=ax+b, 并输出slope(a)、intercept(b)、R2、F值及P值
% 两个变量各自有多时间的栅格数据，范围一致，行列号一致，投影或地理坐标系一致；
% 输入数据应为GeoTiff格式
% 2016.7.14
tic;clear;close all;clc

%%  user

x_pt = 'H:\VI_LP_simu\VIsimu_LP79_miclcover_2000to2012_adjust\ETa_geotif\2000s';% x变量多时间栅格数据文件夹
x_vd = [0, 10000];  % x变量有效数据范围
sfx = 1;  % x scale factor

y_pt = 'H:\VI_LP_simu\VIsimu_LP79_miclcover_2000to2012_adjust\PRP_geotif\2000s';  % y变量多时间栅格数据文件夹
y_vd = [0, 10000];  % y变量有效数值范围
sfy = 1;  % y scale factor

outpt = 'H:\VI_LP_simu\VIsimu_LP79_miclcover_2000to2012_adjust\ETa_PRP_cor';  % 计算结果路径
prfx = 'ET_PRP_VI79adj';  % 输出结果数据前缀
bv = -9999;  % back value

%%  calculate

xfs = dir([x_pt,filesep,'*.tif']);
yfs = dir([y_pt,filesep,'*.tif']);
if length(xfs)~=length(yfs) || (isempty(xfs)&&isempty(yfs))
    errordlg('变量数据量不同！','数据错误')
else
    Ginfo = geotiffinfo([x_pt,filesep,xfs(1).name]);
    Rmat = Ginfo.RefMatrix;
    Rtag = Ginfo.GeoTIFFTags.GeoKeyDirectoryTag;
    
    xdt = []; ydt = [];
    disp('Reading......')
    for fl = 1:length(xfs)
        tmpx = double(imread([x_pt,filesep,xfs(fl).name]));
        tmpx(tmpx<x_vd(1) | tmpx>x_vd(2)) = nan;
        tmpx = tmpx*sfx;
        xdt = cat(3,xdt,tmpx);
        
        tmpy = double(imread([y_pt,filesep,yfs(fl).name]));
        tmpy(tmpy<y_vd(1) | tmpy>y_vd(2)) = nan;
        tmpy = tmpy*sfy;
        ydt = cat(3,ydt,tmpy);
    end
    clearvars tmpx tmpy
    
    if sum(size(xdt)==size(ydt)) ~= 3
        errordlg('变量数据维数不同！','数据错误')
    else
        % slope,intercept,R2,F,P
        rst = nan(Ginfo.Height,Ginfo.Width,5);
        for ir = 1:Ginfo.Height
            for ic = 1:Ginfo.Width
                xtmp = squeeze(xdt(ir,ic,:));
                ytmp = squeeze(ydt(ir,ic,:));
                idxnan = unique([find(isnan(xtmp)); find(isnan(ytmp))]);
                if length(idxnan) <= size(xdt, 3)*0.1   %无效值少于20%
                    xtmp(idxnan) = []; ytmp(idxnan) = [];
                    [b,~,~,~,stats] = regress(ytmp,...
                        [xtmp,ones(length(xtmp),1)]);
                    
                    rst(ir,ic,1) = b(1);  % slope
                    rst(ir,ic,2) = b(2);  % intercept
                    rst(ir,ic,3) = stats(1);  % R2
                    rst(ir,ic,4) = stats(2);  % F
                    rst(ir,ic,5) = stats(3);  % P
                end
            end
            clc
            disp('Calculating......')
            disp([num2str(ir*100/Ginfo.Height),'%'])
        end
        rst(isnan(rst)) = bv;
        
        var = {'slope','intercept','R2','F','P'};
        for m = 1:length(var)
            geotiffwrite([outpt,filesep,prfx,'_',var{m},'.tif'],...
                single(rst(:,:,m)),Rmat,'GeoKeyDirectoryTag',Rtag)
            disp(var{m})
        end
    end
end

mins = toc;
disp(['完成，共用时',num2str(mins/60),'分钟'])
