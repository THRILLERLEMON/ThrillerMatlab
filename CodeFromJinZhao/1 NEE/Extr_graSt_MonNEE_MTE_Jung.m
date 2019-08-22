% Extract monthly NEE flux data from MTE and Jung at the positions of grass site.
% 2017.5.4
clear;close all;clc

%%  input

MTE_NEE_pt = '/home/test2/MTE_NEE/NEE_Org';  % flux
MTEsz = 1/12;

MTEgpr_fl = '/home/test2/MTE_NEE/OtherData/glc2000_10km_grass_bili.tif';  % grass percentile
gprM_sf = 1;

Jung_NEE_pt = '/home/test2/MTE_NEE/JungNEE/Flux/monthly';
Jungsz = 0.5;

Junggpr_fl = '/home/test2/MTE_NEE/JungNEE/Stat/MCD12C1_GraPrc.tif';  % grass percentile
gprJ_sf = 0.01;

yrs = [1982,2011];
mns = [1,12];
gpr_trd = 0.75;

gra_st_fl = '/home/test2/MTE_NEE/NEE_new/Data_contrast/GraALL_LatLon.txt';

outpt = '/home/test2/MTE_NEE/JungNEE/Stat/GraSt';

%%  operate

% find valid grass sites
grarc = dlmread(gra_st_fl);
lats = grarc(:,2);
lons = grarc(:,3);

MTEgpr = imread(MTEgpr_fl);
MTEgpr(MTEgpr==MTEgpr(1,1)) = nan;
MTEgpr = MTEgpr*gprM_sf;
Junggp = imread(Junggpr_fl);
Junggp(Junggp==Junggp(1,1)) = nan;
Junggp = Junggp*gprJ_sf;

Vdsts = [];
for idt = 1:length(lats)
    lat = lats(idt);
    lon = lons(idt);
    
    gprM = MTEgpr(ceil((90-lat)/MTEsz),ceil((lon+180)/MTEsz));
    gprJ = Junggp(ceil((90-lat)/Jungsz),ceil((lon+180)/Jungsz));
    if gprM>=gpr_trd && gprJ>=gpr_trd
        Vdsts = cat(1,Vdsts,grarc(idt,:));
    end
end
lats = Vdsts(:,2);
lons = Vdsts(:,3);
dlmwrite([outpt,'/GraSits',num2str(gpr_trd*100),'_MTE_Jung.txt'],...
    Vdsts,'delimiter',' ')

% MTE ANN MARS RF
rst = nan((yrs(2)-yrs(1)+1)*(mns(2)-mns(1)+1),length(lats),4);
mct = 1;
for yr = yrs(1):yrs(2)
    disp(num2str(yr))
    for mn = mns(1):mns(2)
        MTE_NEEm = double(imread([MTE_NEE_pt,'/',...
            num2str(yr),num2str(mn,'%02d'),'_global_grass_NEE.tif']));
        MTE_NEEm(MTE_NEEm==MTE_NEEm(1,1)) = nan;
        
        ANN_NEEm = double(imread([Jung_NEE_pt,...
            '/CRUNCEPv6.ANN.NEE.monthly.',...
            num2str(yr),num2str(mn,'%02d'),'.tif']));
        ANN_NEEm(ANN_NEEm==ANN_NEEm(1,1)) = nan;
        
        MARS_NEEm = double(imread([Jung_NEE_pt,...
            '/CRUNCEPv6.MARS.NEE.monthly.',...
            num2str(yr),num2str(mn,'%02d'),'.tif']));
        MARS_NEEm(MARS_NEEm==MARS_NEEm(1,1)) = nan;
        
        RF_NEEm = double(imread([Jung_NEE_pt,...
            '/CRUNCEPv6.RF.NEE.monthly.',...
            num2str(yr),num2str(mn,'%02d'),'.tif']));
        RF_NEEm(RF_NEEm==RF_NEEm(1,1)) = nan;
        
        for idt = 1:length(lats)
            rst(mct,idt,1) = MTE_NEEm(ceil((90-lats(idt))/MTEsz),...
                ceil((lons(idt)+180)/MTEsz));  % MTE
            rst(mct,idt,2) = ANN_NEEm(ceil((90-lats(idt))/Jungsz),...
                ceil((lons(idt)+180)/Jungsz));  % ANN
            rst(mct,idt,3) = MARS_NEEm(ceil((90-lats(idt))/Jungsz),...
                ceil((lons(idt)+180)/Jungsz));  % MARS
            rst(mct,idt,4) = RF_NEEm(ceil((90-lats(idt))/Jungsz),...
                ceil((lons(idt)+180)/Jungsz));  % RF
        end
        mct = mct+1;
    end
end
rst(isnan(rst)) = -9999;

% write
ym = [kron((yrs(1):yrs(2))',ones(mns(2)-mns(1)+1,1)),...
    repmat((mns(1):mns(2))',yrs(2)-yrs(1)+1,1)];
stnm = Vdsts(:,1)';
strdt = {'MTE','ANN','MARS','RF'};
for idt = 1:length(strdt)
    dlmwrite([outpt,'/NEEflux_monthly_',strdt{idt},'.txt'],...
        [[-9999,-9999,stnm];[ym,rst(:,:,idt)]])
end

disp('Finish!')
