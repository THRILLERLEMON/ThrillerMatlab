%������������դ��߶��϶�ʱ���������ݵ������R����������P
%�������������ж�ʱ���դ�����ݣ���Χһ�£����к�һ�£�ͶӰ���������ϵһ�£�
%����ֵ��ֵΪ-9999
%��������ӦΪGeoTiff��ʽ
%   JZ 2015.5.30
tic
clear;close all;clc

%%  user

x_path = 'H:\ETa_geotif\2000s';  %x������ʱ��դ�������ļ���
x_valid = [0,10000];   %x������Ч���ݷ�Χ
sfx = 1;  %x scale factor

y_path = 'H:\PRP_geotif\2000s';  %y������ʱ��դ�������ļ���
y_valid = [0,10000];  %y������Ч��ֵ��Χ
sfy = 1;   %y scale factor

outpath = 'H:\ETa_PRP_cor'; %������·��
preffix = 'ET_PRP_VI79adj';  %�������ǰ׺
bv = -9999;

%%  calculate

xfs = dir([x_path,'\*.tif']);
yfs = dir([y_path,'\*.tif']);
if length(xfs)~=length(yfs) || (isempty(xfs) && isempty(yfs))
    errordlg('������������ͬ��', '���ݴ���')
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
        errordlg('��������ά����ͬ��', '���ݴ���')
    else
        rst = nan(Ginfo.Height,Ginfo.Width, 2);
        for ir = 1:Ginfo.Height
            for ic = 1:Ginfo.Width
                xtmp = squeeze(xdata(ir,ic,:));
                ytmp = squeeze(ydata(ir,ic,:));
                idxnan = unique([find(isnan(xtmp)); find(isnan(ytmp))]);
                if length(idxnan)<=size(xdata,3)*0.1   %��Чֵ����10%
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
