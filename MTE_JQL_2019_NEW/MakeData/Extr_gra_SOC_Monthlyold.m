% Extract yearly Manure_Application data from MTE and Jung at the positions of all grass sites.
% Windows 10 1903
% 2019.9.16
% JiQiulei thrillerlemon@outlook.com
clear;close all;clc

%%  input
yrs = [1982,2011];
mns = [1,12];
%դ����Ԫ�Ĵ�С
rsize=1/120;
%վ��ľ�γ����Ϣ
gra_st_fl = 'E:\OFFICE\MTE_NEE_DATA\Gra_LatLon.txt';
outpt = 'E:\OFFICE\MTE_NEE_DATA\GraSitData';
%�����mat�ļ���������Ϊrasdata
load('E:\OFFICE\MTE_NEE_DATA\GSOC\GSOCmap_ExtendGlobal1chu120du.mat')

%%  operate
grarc = dlmread(gra_st_fl);
lats = grarc(:,2);
lons = grarc(:,3);
%������Ž���ľ���
rst = nan((yrs(2)-yrs(1)+1)*(mns(2)-mns(1)+1),length(lats));
%�·ݵļ�����
mct = 1;
for yr = yrs(1):yrs(2)
    rasdata(rasdata==rasdata(1,1)) = nan;
    for mn = mns(1):mns(2)
        for ist = 1:length(lats)
            rst(mct,ist) = rasdata(ceil((90-lats(ist))/rsize),...
                ceil((lons(ist)+180)/rsize));  % MTE
        end
        mct = mct+1;
    end
    disp(num2str(yr))
end

ym = [kron((yrs(1):yrs(2))',ones(mns(2)-mns(1)+1,1)),...
    repmat((mns(1):mns(2))',yrs(2)-yrs(1)+1,1)];
dlmwrite([outpt,'\GSOC_SiteMonthly.txt'],...
    [ym,rst])

disp('Finish!')