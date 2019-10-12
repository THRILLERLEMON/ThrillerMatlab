% Extract yearly NEE flux data from MTE and Jung at the positions of all grass sites.
% 2017.4.18
clear;close all;clc

%%  input

MTE_NEE_pt = '/home/test2/MTE_NEE/NEE_new/yflux/all';  % flux
hdm = 'NEEgra_FluxSum_';
ftm = '_01to12.tif';

yrs = [1982,2011];

gra_st_fl = '/home/test2/MTE_NEE/NEE_new/Data_contrast/GraALL_LatLonRowCol.txt';

outpt = '/home/test2/MTE_NEE/NEE_new/Data_contrast/siteNEE';

%%  operate

grarc = dlmread(gra_st_fl);
lats = grarc(:,2);
lons = grarc(:,3);

rst = nan(yrs(2)-yrs(1)+1,length(lats));
for yr = yrs(1):yrs(2)
    NEEm = double(imread([MTE_NEE_pt,'/',hdm,num2str(yr),ftm]));
    
    for ist = 1:length(lats)
        rst(yr-yrs(1)+1,ist) = NEEm(ceil((90-lats(ist))/(1/12)),...
            ceil((lons(ist)+180)/(1/12)));  % MTE
    end
    
    disp(num2str(yr))
end

dlmwrite([outpt,'/NEEflux_annual_AllSites.txt'],...
    [(yrs(1):yrs(2))',rst])

disp('Finish!')
