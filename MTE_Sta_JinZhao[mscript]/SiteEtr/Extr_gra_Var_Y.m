% Extract monthly NEE at the positions of all grass sites.
% PRP TEM SWR
% 2017.4.23
clear;close all;clc

%%  input

VAR_pt = '/home/LiShuai/Data/Grass_Management/Intensive_frac';
hdn = '';
fts = '_Intensvie_frac.tif';
rsize = 0.5;

gra_st_fl = '/home/test2/MTE_NEE/NEE_new/Data_contrast/GraALL_LatLon.txt';

outfl = '/home/test2/MTE_NEE/SiteEtr/Intensive_frac.txt';

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
    VARm = double(imread([VAR_pt,'/',hdn,num2str(yr),fts]));
    VARm(VARm==VARm(1,1)) = nan;
    for mn = mns(1):mns(2)
        for ist = 1:length(lats)
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
