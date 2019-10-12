% Calculate the annual regional NEE flux of grids which are both grassland in MTE and Jung.
% geotiff
% 2017.5.8
clear;close all;clc

%%  input

NEEfm_pt = '/home/test2/MTE_NEE/NEE_new02/yflux';
GrapcM_fl = '/home/test2/MTE_NEE/OtherData/glc2000_10km_grass_bili.tif';

NEEfj_pt = '/home/test2/MTE_NEE/JungNEE/Flux/yearly';
GrapcJ_fl = '/home/test2/MTE_NEE/JungNEE/Stat/Gra_MCD12C1_sts/MCD12C1_GraPrc.tif';

gpc = 0.85;

outpt = '/home/test2/MTE_NEE/JungNEE/BothGraGrid';

%%  operate

% Grass percent
GrapcM = double(imread(GrapcM_fl));  % 1752 4320
GrapcM(GrapcM==GrapcM(1,1)) = nan;
GrapcM(GrapcM<gpc) = nan;

GrapcJ = double(imread(GrapcJ_fl));  % 360 720
GrapcJ(GrapcJ==GrapcJ(1,1)) = nan;
GrapcJ(GrapcJ<gpc*100) = nan;

GrapcJ2 = nan(292,720);
GrapcM2 = nan(1752,4320);
for ir = 1:292
    for ic = 1:720
        tmpJ = GrapcJ(ir,ic);
        if ~isnan(tmpJ)
            tmpM = GrapcM(6*(ir-1)+1:6*ir,6*(ic-1)+1:6*ic);
            if any(~isnan(tmpM(:)))
                GrapcJ2(ir,ic) = GrapcJ(ir,ic);
                GrapcM2(6*(ir-1)+1:6*ir,6*(ic-1)+1:6*ic) = tmpM;
            end
        end
    end
end

% area
S1 = referenceSphere('earth','km');

wdzone = ones(292,720);
RmatJ = makerefmat('RasterSize',[292 720],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');
[~,colarea] = areamat(wdzone,RmatJ,S1);
wdaJ = repmat(colarea,1,720);
wdaJ(isnan(GrapcJ2)) = nan;

wdzone = ones(1752,4320);
RmatM = makerefmat('RasterSize',[1752 4320],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');
[~,colarea] = areamat(wdzone,RmatM,S1);
wdaM = repmat(colarea,1,4320);
wdaM(isnan(GrapcM2)) = nan;

GrapcM2(isnan(GrapcM2)) = -9999;
GrapcJ2(isnan(GrapcJ2)) = -9999;
geotiffwrite([outpt,'/MTE_BothGra',num2str(gpc*100),'.tif'],...
    single(GrapcM2),RmatM);
geotiffwrite([outpt,'/Jung_BothGra',num2str(gpc*100),'.tif'],...
    single(GrapcJ2),RmatJ);

% 
yrs = [1982,2011];
rst = nan(yrs(2)-yrs(1)+1,4);  % MTE ANN MARS RF
for yr = yrs(1):yrs(2)
    MTE = double(imread([NEEfm_pt,'/NEEgra_FluxSum_',...
        num2str(yr),'_01to12.tif']));
    MTE(MTE==MTE(1,1)) = nan;
    MTE = MTE.*wdaM;
    wdaM2 = wdaM;
    wdaM2(isnan(MTE)) = nan;
    rst(yr-yrs(1)+1,1) = nansum(MTE(:))/nansum(wdaM2(:));
    
    ANN = double(imread([NEEfj_pt,'/ANN/CRUNCEPv6.ANN.NEE.annual.',...
        num2str(yr),'.tif']));
    ANN(ANN==ANN(1,1)) = nan;
    ANN = ANN(1:292,:).*wdaJ;
    wdaJann = wdaJ;
    wdaJann(isnan(ANN)) = nan;
    rst(yr-yrs(1)+1,2) = nansum(ANN(:))/nansum(wdaJann(:));
    
    MARS = double(imread([NEEfj_pt,'/MARS/CRUNCEPv6.MARS.NEE.annual.',...
        num2str(yr),'.tif']));
    MARS(MARS==MARS(1,1)) = nan;
    MARS = MARS(1:292,:).*wdaJ;
    wdaJmars = wdaJ;
    wdaJmars(isnan(MARS)) = nan;
    rst(yr-yrs(1)+1,3) = nansum(MARS(:))/nansum(wdaJmars(:));
    
    RF = double(imread([NEEfj_pt,'/RF/CRUNCEPv6.RF.NEE.annual.',...
        num2str(yr),'.tif']));
    RF(RF==RF(1,1)) = nan;
    RF = RF(1:292,:).*wdaJ;
    wdaJrf = wdaJ;
    wdaJrf(isnan(RF)) = nan;
    rst(yr-yrs(1)+1,4) = nansum(RF(:))/nansum(wdaJrf(:));
    
    disp(num2str(yr))
end

dlmwrite([outpt,'/BothGrasGrids_',num2str(gpc*100),'.txt'],...
    rst,'delimiter',' ')

disp('Finish!')

