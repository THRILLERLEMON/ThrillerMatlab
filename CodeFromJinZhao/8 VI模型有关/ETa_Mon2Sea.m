% ETa month to season
% spring��3��4��5��summer��6��7��8��autumn��9��10��11��winter��12��1��2
% geotiff
clear;close all;clc

%%  user

ETapt = 'H:\VI_LP_simu_infat\VI_diffLucc01\LP_out_tif\PRP\mon';  % ETa�����ݴ洢�ļ���
head = 'PRP';  % �ļ���������Ϣǰ�ַ���
foot = '.tif';  % �ļ���������Ϣ���ַ���

yrs = [1982, 2012];  % ������ֹ���
valid = [0, 2000];  % ETa��Ч��Χ

sts = 2;  % ͳ�Ʒ��� 1.��ֵ  2.�ܺ�

outbv = -9999;
outhead = 'PRPsn_';  % ����ļ���ͷ
outpt = 'H:\VI_LP_simu_infat\VI_diffLucc01\LP_out_tif\PRP\season';  % ������·��

%%  calculate

switch sts
    case 1
        stsfun = @(x)nanmean(x,3);
        stsrt = 'mean';
    case 2
        stsfun = @(x)nansum(x,3);
        stsrt = 'sum';
end

disp('Make dir')
docnm = {'MAM', 'JJA', 'SON', 'DJF'};
for seas = 1:4
    mkdir(outpt, docnm{seas});
end

afs = dir([ETapt,filesep,'*.tif']);
Rinfo = geotiffinfo([ETapt,filesep,afs(1).name]);

disp('Calculate:')
for yr = yrs(1):yrs(2)
    disp(num2str(yr))
    montmp = nan(Rinfo.Height, Rinfo.Width, 12);
    for mon = 1:12
        if mon >= 3
            montmp(:, :, mon-2) = ...
                double(imread([ETapt,filesep,head,num2str(yr),num2str(mon,'%02d'),foot]));
        else
            if yr~=yrs(2)
                montmp(:, :, mon + 10) = ...
                    double(imread([ETapt,filesep,head,num2str(yr+1),num2str(mon,'%02d'),foot]));
            end
        end
    end
    
    montmp(montmp<valid(1) | montmp>valid(2)) = nan;
    for seas = 1:3+(yr~=yrs(2))
        tmp = montmp(:,:,1+3*(seas-1):3+3*(seas-1));
        searas = stsfun(tmp);
        idxsea = sum(~isnan(tmp),3);
        searas(idxsea==0) = outbv;
        geotiffwrite([outpt,filesep,docnm{seas},filesep,outhead,num2str(yr),docnm{seas},'_',stsrt,'.tif'], ...
            searas, Rinfo.RefMatrix, 'GeoKeyDirectoryTag', Rinfo.GeoTIFFTags.GeoKeyDirectoryTag)
        disp(docnm{seas})
    end
end

disp('Finish!')
