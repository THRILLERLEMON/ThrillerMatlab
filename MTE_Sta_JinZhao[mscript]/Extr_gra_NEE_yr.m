% Extract yearly NEE flux data from MTE and Jung at the positions of grass site.
% 2017.4.18
clear;close all;clc

%%  input

MTE_NEE_pt = '/home/test2/MTE_NEE/NEE_new/yflux/all';  % flux
hdm = 'NEEgra_FluxSum_';
ftm = '_01to12.tif';

Jung_NEE_ANN_pt = '/home/test2/MTE_NEE/JungNEE/yearly/ANN';
hda = 'CRUNCEPv6.ANN.NEE.annual.';
fta = '.tif';

Jung_NEE_RF_pt = '/home/test2/MTE_NEE/JungNEE/yearly/RF';
hdr = 'CRUNCEPv6.RF.NEE.annual.';
ftr = '.tif';

yrs = [1982,2011];

gra_st_fl = '/home/test2/MTE_NEE/NEE_new/Data_contrast/Gra70_LatLonRowCol.txt';

outpt = '/home/test2/MTE_NEE/NEE_new/Data_contrast/siteNEE';

%%  operate

grarc = dlmread(gra_st_fl);
lats = grarc(:,2);
lons = grarc(:,3);
rowg = grarc(:,4);
colg = grarc(:,5);

rst = nan(yrs(2)-yrs(1)+1,3,length(lats));
for yr = yrs(1):yrs(2)
    NEEm = double(imread([MTE_NEE_pt,'/',hdm,num2str(yr),ftm]));
    NEEa = double(imread([Jung_NEE_ANN_pt,'/',hda,num2str(yr),fta]));
    NEEr = double(imread([Jung_NEE_RF_pt,'/',hdr,num2str(yr),ftr]));
    
    for ist = 1:length(lats)
        rst(yr-yrs(1)+1,1,ist) = NEEm(ceil((90-lats(ist))/(1/12)),...
            ceil((lons(ist)+180)/(1/12)));  % MTE
        rst(yr-yrs(1)+1,2,ist) = NEEa(rowg(ist),colg(ist));  % ANN
        rst(yr-yrs(1)+1,3,ist) = NEEr(rowg(ist),colg(ist));  % RF
    end
    
    disp(num2str(yr))
end

stnm = grarc(:,1);
for ist = 1:length(stnm)
    dlmwrite([outpt,'/NEEflux_annual_',num2str(stnm(ist),'%02d'),'.txt'],...
        [(yrs(1):yrs(2))',rst(:,:,ist)])
end

disp('Finish!')

