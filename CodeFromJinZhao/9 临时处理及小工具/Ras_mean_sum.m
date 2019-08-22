% �����ļ����¶��դ�����ݾ�ֵ�����ֵ��
% ��������ӦͶӰ��ͬ����Χһ�¡����к���ͬ����ʽ��Ϊgeotiff
% 2015.5.31
clear;clc;close all

%%  user

ras_path = 'E:\ISI-MIP_GPP_Pre_SWrad\Gfdl-esm2m_extract\PRP_yr\fur_VI1km30s';    % ���������ļ���
valid = [0,2000];    % ����������Ч��ֵ��Χ
sf = 1; % ��������scale factor

stats = 1;    % ͳ������ 1.��ֵ 2.�ܺ� 3.���ֵ 4.��׼�� 5.CV

outbv = -9999; % ����������ֵ
prefix = 'pr_bced_1960_1999_gfdl-esm2m_rcp8p5_2030s_LPsqr';  % �������ǰ׺
outpath = 'E:\ISI-MIP_GPP_Pre_SWrad\Gfdl-esm2m_extract\PRP_yr\fur_VI1km30s_mean'; % ����ļ���

%%  calculate

fs = dir([ras_path,'\*.tif']);

Ginfo = geotiffinfo([ras_path,'\',fs(1).name]);

rtmp = nan(Ginfo.Height, Ginfo.Width, length(fs));
for i = 1:length(fs)
    temp = double(imread([ras_path,'\',fs(i).name]));
    temp(temp<valid(1) | temp>valid(2)) = nan;
    rtmp(:,:,i) = temp*sf;
    clc
    disp('Reading...')
    disp([num2str(i*100/length(fs)),'%'])
end

switch stats
    case 1
        rst = nanmean(rtmp,3);
    case 2
        rst = sum(rtmp,3);
    case 3
        rst = nanmax(rtmp,[],3);
    case 4
        % rst = std(rtmp,0,3,'omitnan');
        rst = nanstd(rtmp,0,3);
    case 5
        % rst = std(rtmp,0,3,'omitnan')./nanmean(rtmp,3);
        rst = nanstd(rtmp,0,3)./nanmean(rtmp,3);
    otherwise
        errordlg('��Чͳ�Ʒ�����','stats����')
end
suffix = {'mean','sum','max','std','CV'};

rst(sum(~isnan(rtmp),3)==0) = nan;
rst(isnan(rst)) = outbv;
geotiffwrite([outpath,'\',prefix,'_',suffix{stats},'.tif'],single(rst),...
    Ginfo.RefMatrix,'GeoKeyDirectoryTag',Ginfo.GeoTIFFTags.GeoKeyDirectoryTag)

disp('Finish!')
