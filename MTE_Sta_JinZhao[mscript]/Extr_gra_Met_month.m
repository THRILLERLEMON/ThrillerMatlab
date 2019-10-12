% Extract monthly meteorological at the positions of all grass sites.
% PRP TEM SWR
% 2017.4.20
clear;close all;clc

%%  input

PRP_pt = '/home/datastore/source/raster/Params/Pre/Global/198201_201112_CRU-3.22-0.5D';
hdp = 'CRU-TS3.22_PRE_';

TEM_pt = '/home/datastore/source/raster/Params/Tem/Global/198201_201112_CRU-3.22-0.5D';
hdt = 'CRU-TS3.22_TEM_';

gra_st_fl = '/home/test2/MTE_NEE/NEE_new/Data_contrast/GraALL_LatLon.txt';

outpt = '/home/test2/MTE_NEE/MeteoData/SiteMon';

%%  operate

yrs = [1982,2011];
mns = [1,12];

grarc = dlmread(gra_st_fl);
lats = grarc(:,2);
lons = grarc(:,3);

rst = nan((yrs(2)-yrs(1)+1)*(mns(2)-mns(1)+1),length(lats),2);
mct = 1;
for yr = yrs(1):yrs(2)
    disp(num2str(yr))
    for mn = mns(1):mns(2)
        PRPm = double(imread([PRP_pt,'/',hdp,...
            num2str(yr),num2str(mn,'%02d'),'.tif']));
        PRPm(PRPm==PRPm(1,1)) = nan;
        
        TEMm = double(imread([TEM_pt,'/',hdt,...
            num2str(yr),num2str(mn,'%02d'),'.tif']));
        TEMm(TEMm==TEMm(1,1)) = nan;
        
        for ist = 1:length(lats)
            rst(mct,ist,1) = PRPm(ceil((90-lats(ist))/0.5),...
                ceil((lons(ist)+180)/0.5));  % PRP
            rst(mct,ist,2) = TEMm(ceil((90-lats(ist))/0.5),...
                ceil((lons(ist)+180)/0.5));  % TEM
        end
        mct = mct+1;
    end
end

ym = [kron((yrs(1):yrs(2))',ones(mns(2)-mns(1)+1,1)),...
    repmat((mns(1):mns(2))',yrs(2)-yrs(1)+1,1)];
mstr = {'PRP','TEM'};
for imt = 1:2
    dlmwrite([outpt,'/',mstr{imt},'_month_AllSites.txt'],...
        [ym,rst(:,:,imt)])
end

disp('Finish!')

