% Calculate the control factor of NEE variance and count the percentage of
% the area of control factors in each zone.
% geotiff LINUX
% 2017.8.31
close all;clear

%%  input

VarCv_pt = '/home/test2/MTE_NEE/CovVar/yflux';

clmgs_fl = '/home/test2/MTE_NEE/OtherData/Gras_Clim.tif';  % climate of grassland
grabl_fl = '/home/test2/MTE_NEE/OtherData/glc2000_10km_grass_bili.tif';

bv = -99;
outpt = '/home/test2/MTE_NEE/CovVar/yflux/stats';

%%  operate

clmgs = double(imread(clmgs_fl));
clmgs(clmgs==clmgs(1,1)) = nan;
clmgs2 = clmgs(:);
clmgs2(isnan(clmgs2)) = [];
uqclm = unique(clmgs2(:));
clearvars clmgs2

S1 = referenceSphere('earth','km');
wdzone = ones(1752,4320);
Rmat = makerefmat('RasterSize',[1752 4320],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');
[~,colarea] = areamat(wdzone,Rmat,S1);
wdarea = repmat(colarea,1,4320);

grabl = double(imread(grabl_fl));
grabl(grabl==grabl(1,1)) = nan;

wdar_gr = wdarea.*grabl;

GPPvr = double(imread([VarCv_pt,'/GPP_var_1982to2011.tif']));
GPPvr(GPPvr==GPPvr(1,1)) = nan;
Revr = double(imread([VarCv_pt,'/Re_var_1982to2011.tif']));
Revr(Revr==Revr(1,1)) = nan;
Ng2cv = double(imread([VarCv_pt,'/GPP_Re_Ng2cvar_1982to2011.tif']));
Ng2cv(Ng2cv==Ng2cv(1,1)) = nan;

NEEvr = GPPvr+Revr+Ng2cv;
GPPpc = GPPvr*100./NEEvr;
Repc = Revr*100./NEEvr;
Ng2pc = Ng2cv*100./NEEvr;
idn = isnan(GPPpc+Repc+Ng2pc);
[~,Vrctr] = max(abs(cat(3,GPPpc,Repc,Ng2pc)),[],3);
Vrctr(idn) = nan;

wdar_gr(isnan(Vrctr)) = nan;

rst = nan(length(uqclm),3,2);
for clm = 1:length(uqclm)
    ar_zn = nansum(wdar_gr(clmgs==uqclm(clm)));
    ar_gpp = nansum(wdar_gr(clmgs==uqclm(clm) & Vrctr==1));
    ar_re = nansum(wdar_gr(clmgs==uqclm(clm) & Vrctr==2));
    ar_n2 = nansum(wdar_gr(clmgs==uqclm(clm) & Vrctr==3));
    
    rst(clm,:,1) = [ar_gpp,ar_re,ar_n2];
    rst(clm,:,2) = [ar_gpp*100/ar_zn,ar_re*100/ar_zn,ar_n2*100/ar_zn];
end

dlmwrite([outpt,'/NEE_VarCtr_Area.txt'],[uqclm,rst(:,:,1)],'delimiter',' ')
dlmwrite([outpt,'/NEE_VarCtr_AreaPrc.txt'],[uqclm,rst(:,:,2)],'delimiter',' ')

Vrctr(isnan(GPPvr)) = bv;
geotiffwrite([outpt,'/NEE_VarCtr.tif'],int8(Vrctr),Rmat)

disp('Finish!')

