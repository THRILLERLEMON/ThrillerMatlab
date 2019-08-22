% ����դ������R2��Slope��Fֵ��Pֵ��������slopeֵ
% ��������Ϊgeotiff����Χһ������������ͬ
% JZ 2017.3.27
tic
clear;clc;close all;

%%  user

ras_path = 'D:\Franz\ETinversGPP\ET_PRP_gaps\PRP_GIDS\MnEle65Neg30stSmth2_crct_VerticalZonal_82to12Yr\PRPmnsET';    %դ�����ݴ洢·��
valid = [-1000,1000];    %����������Чֵ��Χ
sf = 1;  %scale factor

psig = 0.05;  % Pֵ������ˮƽ

outpath = 'D:\Franz\ETinversGPP\ET_PRP_gaps\PRP_GIDS\MnEle65Neg30stSmth2_crct_VerticalZonal\PRPmnsET_slp\org'; %����洢·��
prefix = 'VI_ETmnsPRP_1982to2012_PRP_crct';   %�������ǰ׺
bvalue = -9999;  %������ݱ���ֵ

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
            %if b(2) ~= 0  %��Ч��Χ�ڳ��ֵ���Ч����
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
disp(['��ɣ�����ʱ',num2str(mins/60),'����'])
