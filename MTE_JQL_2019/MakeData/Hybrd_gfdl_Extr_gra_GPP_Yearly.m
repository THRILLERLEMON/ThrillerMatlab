% Extract yearly GPP at the positions of all grass sites.
% Windows 10 1903
% 2019.9.11
% JiQiulei thrillerlemon@outlook.com
clear;close all;clc

%%  input
VAR_pt = 'C:\\Users\\thril\\Desktop\\MTEtest';
%�ļ�ͷ
hdn = 'hybrid_gfdl-esm2m_co2_gpp_';
%�ļ�β
fts = '.tif';
%դ����Ԫ�Ĵ�С
rsize = 1/2;
%վ��ľ�γ����Ϣ
gra_st_fl = 'C:\\Users\\thril\\Desktop\\MTEtest\\Gra_LatLon.txt';
outfl = 'C:\\Users\\thril\\Desktop\\MTEtest\\Extensive_GPPyearly.txt';

%%  operate
yrs = [2006,2010];
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
    VARm = double(imread([VAR_pt,'\\',hdn,num2str(yr),fts]));
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