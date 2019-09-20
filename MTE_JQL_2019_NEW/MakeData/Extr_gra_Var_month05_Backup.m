% Extract monthly NEE at the positions of all grass sites.
% PRP TEM SWR
% 2017.4.23
clear;close all;clc

%%  input
VAR_pt = '/home/LiShuai/Data/Grass_Management/Extensive_frac';
%�ļ�ͷ
hdn = '';
%�ļ�β
fts = '_Extensive_fraction.tif';
%դ����Ԫ�Ĵ�С
rsize = 1/2;
%վ��ľ�γ����Ϣ
gra_st_fl = '/home/test2/MTE_NEE/NEE_new/Data_contrast/GraALL_LatLon.txt';
outfl = '/home/LiShuai/Data/Extensive_frac.txt';

%%  operate
yrs = [1982,2011];
mns = [1,12];

grarc = dlmread(gra_st_fl);
lats = grarc(:,2);
lons = grarc(:,3);
%������Ž���ľ���
rst = nan((yrs(2)-yrs(1)+1)*(mns(2)-mns(1)+1),length(lats));
%�·ݵļ�����
mct = 1;

for yr = yrs(1):yrs(2)
    disp(num2str(yr))
    VARm = double(imread([VAR_pt,'/',hdn,num2str(yr),fts]));
    %���ñ���ֵ
    VARm(VARm==VARm(1,1)) = nan;
    %ѭ��12����
    for mn = mns(1):mns(2)
        %ѭ��44��վ��
        for ist = 1:length(lats)
            %��ȡ��Ӧ��γ�ȵ�ֵ���Զ�Ϊ��׼�����ж�ȡ�����ͼ�е�ֵ
            rst(mct,ist) = VARm(ceil((90-lats(ist))/rsize),...
                ceil((lons(ist)+180)/rsize));  % VAR
        end
        mct = mct+1;
    end
end

ym = [kron((yrs(1):yrs(2))',ones(mns(2)-mns(1)+1,1)),...
    repmat((mns(1):mns(2))',yrs(2)-yrs(1)+1,1)];

dlmwrite(outfl,[ym,rst])
disp('Finish!')