% ������������դ��߶��϶�ʱ���������ݵ����Իع�: y=ax+b, �����slope(a)��intercept(b)��R2��Fֵ��Pֵ
% �������������ж�ʱ���դ�����ݣ���Χһ�£����к�һ�£�ͶӰ���������ϵһ�£�
% ��������ӦΪGeoTiff��ʽ
% 2016.7.14
tic;clear;close all;clc

%%  user

x_pt = 'H:\VI_LP_simu\VIsimu_LP79_miclcover_2000to2012_adjust\ETa_geotif\2000s';% x������ʱ��դ�������ļ���
x_vd = [0, 10000];  % x������Ч���ݷ�Χ
sfx = 1;  % x scale factor

y_pt = 'H:\VI_LP_simu\VIsimu_LP79_miclcover_2000to2012_adjust\PRP_geotif\2000s';  % y������ʱ��դ�������ļ���
y_vd = [0, 10000];  % y������Ч��ֵ��Χ
sfy = 1;  % y scale factor

outpt = 'H:\VI_LP_simu\VIsimu_LP79_miclcover_2000to2012_adjust\ETa_PRP_cor';  % ������·��
prfx = 'ET_PRP_VI79adj';  % ����������ǰ׺
bv = -9999;  % back value

%%  calculate

xfs = dir([x_pt,filesep,'*.tif']);
yfs = dir([y_pt,filesep,'*.tif']);
if length(xfs)~=length(yfs) || (isempty(xfs)&&isempty(yfs))
    errordlg('������������ͬ��','���ݴ���')
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
        errordlg('��������ά����ͬ��','���ݴ���')
    else
        % slope,intercept,R2,F,P
        rst = nan(Ginfo.Height,Ginfo.Width,5);
        for ir = 1:Ginfo.Height
            for ic = 1:Ginfo.Width
                xtmp = squeeze(xdt(ir,ic,:));
                ytmp = squeeze(ydt(ir,ic,:));
                idxnan = unique([find(isnan(xtmp)); find(isnan(ytmp))]);
                if length(idxnan) <= size(xdt, 3)*0.1   %��Чֵ����20%
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
disp(['��ɣ�����ʱ',num2str(mins/60),'����'])
