% Extract monthly meteorological at the positions of all grass sites.
% PRP TEM SWR
% 2017.4.20
clear;close all;clc

%%  input

NEE_pt = '/home/LiShuai/NEE_Train_for_upscale/Result_1';
hdn = '';
fts = '_global_grass_NEE.tif';
rsize = 1/12;

gra_st_fl = '/home/test2/MTE_NEE/NEE_new/Data_contrast/GraALL_LatLon.txt';

outpt = '/home/test2/MTE_NEE/NEE_new/SiteMon';

%%  operate

yrs = [1982,2011];
mns = [1,12];

grarc = dlmread(gra_st_fl);
lats = grarc(:,2);
lons = grarc(:,3);

rst = nan((yrs(2)-yrs(1)+1)*(mns(2)-mns(1)+1),length(lats));
mct = 1;
for yr = yrs(1):yrs(2)
    disp(num2str(yr))
    for mn = mns(1):mns(2)
        NEEm = double(imread([NEE_pt,'/',hdn,...
            num2str(yr),num2str(mn,'%02d'),fts]));
        NEEm(NEEm==NEEm(1,1)) = nan;
        
        for ist = 1:length(lats)
            rst(mct,ist) = NEEm(ceil((90-lats(ist))/rsize),...
                ceil((lons(ist)+180)/rsize));  % NEE
        end
        mct = mct+1;
    end
end
rst(isnan(rst)) = -9999;

ym = [kron((yrs(1):yrs(2))',ones(mns(2)-mns(1)+1,1)),...
    repmat((mns(1):mns(2))',yrs(2)-yrs(1)+1,1)];

dlmwrite([outpt,'/NEE_month_AllSites.txt'],[ym,rst])

disp('Finish!')

