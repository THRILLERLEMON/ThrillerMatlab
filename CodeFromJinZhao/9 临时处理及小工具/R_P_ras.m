%计算两个变量栅格尺度上多时间序列数据的相关性R及置信区间P
%两个变量各自有多时间的栅格数据，范围一致，行列号一致，投影或地理坐标系一致；
%背景值赋值为-9999
%输入数据应为GeoTiff格式
%   JZ 2015.5.30
tic
clear;close all;clc

%%  user

x_path = 'H:\ETa_geotif\2000s';  %x变量多时间栅格数据文件夹
x_valid = [0,10000];   %x变量有效数据范围
sfx = 1;  %x scale factor

y_path = 'H:\PRP_geotif\2000s';  %y变量多时间栅格数据文件夹
y_valid = [0,10000];  %y变量有效数值范围
sfy = 1;   %y scale factor

outpath = 'H:\ETa_PRP_cor'; %计算结果路径
preffix = 'ET_PRP_VI79adj';  %结果数据前缀
bv = -9999;

%%  calculate

xfs = dir([x_path,'\*.tif']);
yfs = dir([y_path,'\*.tif']);
if length(xfs)~=length(yfs) || (isempty(xfs) && isempty(yfs))
    errordlg('变量数据量不同！', '数据错误')
else
    Ginfo = geotiffinfo([x_path,'\',xfs(1).name]);
    Rmat = Ginfo.RefMatrix;
    Rtag = Ginfo.GeoTIFFTags.GeoKeyDirectoryTag;
    
    xdata = []; ydata = [];
    disp('Reading......')
    for f1 = 1:length(xfs)
        tmpx = double(imread([x_path,'\',xfs(f1).name]));
        tmpx(tmpx<x_valid(1) | tmpx>x_valid(2)) = nan;
        tmpx = tmpx*sfx;
        xdata = cat(3,xdata,tmpx);
        
        tmpy = double(imread([y_path,'\',yfs(f1).name]));
        tmpy(tmpy<y_valid(1) | tmpy>y_valid(2)) = nan;
        tmpy = tmpy*sfy;
        ydata = cat(3,ydata,tmpy);
    end
    if sum(size(xdata)==size(ydata))~=3
        errordlg('变量数据维数不同！', '数据错误')
    else
        rst = nan(Ginfo.Height,Ginfo.Width, 2);
        for ir = 1:Ginfo.Height
            for ic = 1:Ginfo.Width
                xtmp = squeeze(xdata(ir,ic,:));
                ytmp = squeeze(ydata(ir,ic,:));
                idxnan = unique([find(isnan(xtmp)); find(isnan(ytmp))]);
                if length(idxnan)<=size(xdata,3)*0.1   %无效值少于10%
                    xtmp(idxnan) = []; ytmp(idxnan) = [];
                    [corr,pvalue] = corrcoef(xtmp,ytmp);
                    rst(ir,ic,1) = corr(1,2);
                    rst(ir,ic,2) = pvalue(1,2);
                end
            end
            clc
            disp('Calculating......')
            disp([num2str(ir*100/Ginfo.Height),'%'])
        end
        rst(isnan(rst)) = bv;
        geotiffwrite([outpath,'\',preffix,'_corr.tif'],...
            single(rst(:,:,1)),Rmat,'GeoKeyDirectoryTag',Rtag)
        disp([outpath,'\',preffix,'_corr.tif'])
        geotiffwrite([outpath,'\',preffix,'_p.tif'],...
            single(rst(:,:,2)),Rmat,'GeoKeyDirectoryTag',Rtag)
        disp([outpath,'\',preffix,'_p.tif'])
        disp('OK!')
    end
end
disp(['Spend time:',num2str(toc/60),' minutes'])
