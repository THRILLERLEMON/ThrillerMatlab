%  �����ݼ�����ƽ���������ڴ�����
%  geotiff
clear;close all;clc;tic

%%  Input

dayras_pt = 'H:\MOD09A1.v6\MOD09A1_tiff';  % ������Ŀ¼
heads = 'MOD09A1.A';  % �������ļ���������Ϣǰ�ַ��� "yyyyddd"
vd = [0, 1];  % valid range
sf = 1;  % scale factor

ygap = [2000, 2012];  % �������
mgap = [4, 9];  % �����·�

outbv = -9999;  % �������ֵ
outpt = 'H:\MOD09A1.v6\������albedo\yr_grow';  % ����洢·��

%%  Operate

afs = dir([dayras_pt, '\*.tif']);
Rinfo = geotiffinfo([dayras_pt, '\', afs(1).name]);

monp = [31,28,31,30,31,30,31,31,30,31,30,31];
monr=monp;monr(2)=29;

stedp = [sum(monp(1:mgap(1)-1))+1, sum(monp(1:mgap(2)))];
stedr = [sum(monr(1:mgap(1)-1))+1, sum(monr(1:mgap(2)))];

result = nan(Rinfo.Height, Rinfo.Width);
for yr = ygap(1):ygap(2)
    if mod(yr,400)==0||(mod(yr,4)==0 && mod(yr,100)~=0)
        sted = stedr;
    else
        sted = stedp;
    end
    dfs = dir([dayras_pt,'\',heads,num2str(yr),'*.tif']);
    
    result = [];
    vdys = [];
    for dy = 1:length(dfs)
        doy=str2double(dfs(dy).name(length(heads)+5:length(heads)+7));
        if doy>=sted(1) && doy<=sted(2)
            tmp = double(imread([dayras_pt,'\',dfs(dy).name]));
            tmp(tmp<vd(1) | tmp>vd(2)) = nan;
            tmp = tmp*sf;
            result = nansum(cat(3,result,tmp), 3);
            vdys = cat(3,vdys,~isnan(tmp));
        end
        
        clc
        disp([num2str(yr),':',num2str(dy*100/length(dfs)),'%'])
    end
    result = result ./ sum(vdys,3);
    result(isnan(result)) = outbv;
    
    geotiffwrite([outpt,'\',heads,num2str(yr),'.tif'], result, ...
        Rinfo.RefMatrix, 'GeoKeyDirectoryTag', Rinfo.GeoTIFFTags.GeoKeyDirectoryTag)
end

mins = toc;
disp(['��ɣ�����ʱ', num2str(mins / 60), '����'])
