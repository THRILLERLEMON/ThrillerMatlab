% Count the area and mean NEE in different Hotpot levels.
% Linux
% 2019.10.4
% JiQiulei thrillerlemon@outlook.com
clear;close all;clc

%%  input

NEE_fl = '/home/test2/MTE_NEE/NEE_new02/ymean/NEEfluxsum_82to11_mean.tif';
PRP_fl = '/home/test2/MTE_NEE/MeteoData/Mean/PRP_82to11_mean.tif';
TEM_fl = '/home/test2/MTE_NEE/MeteoData/Mean/TEM_82to11_mean.tif';
HotPs_fl = '/home/test2/MTE_NEE/NEE_new02/hotspots/NEEtotal_82to12_Hotspots.tif';
MetCt_fl = '/home/test2/MTE_NEE/NEE_new02/Pcor/met_P_T/NEEgraFlxMet2_min.tif';

grabl_fl = '/home/test2/MTE_NEE/OtherData/glc2000_10km_grass_bili.tif';

outpt = '/home/test2/MTE_NEE/NEE_new02/hotspots/Metsts';

%%  operate

NEE = double(imread(NEE_fl));
NEE(NEE==NEE(1,1)) = nan;

PRP = double(imread(PRP_fl));
PRP(PRP==PRP(1,1)) = nan;
PRP(isnan(NEE)) = nan;

TEM = double(imread(TEM_fl));
TEM(TEM==TEM(1,1)) = nan;
TEM(isnan(NEE)) = nan;

HotPs = double(imread(HotPs_fl));
HotPs(HotPs==HotPs(1,1)) = nan;

MetCt = double(imread(MetCt_fl));
MetCt(MetCt==MetCt(1,1)) = nan;

%
S1 = referenceSphere('earth','km');
wdzone = ones(1752,4320);
Rmat = makerefmat('RasterSize',[1752 4320],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');
[~,colarea] = areamat(wdzone,Rmat,S1);
wdarea = repmat(colarea,1,4320);
wdarea(isnan(NEE)) = nan;

grabl = double(imread(grabl_fl));
grabl(grabl==grabl(1,1)) = nan;

%
wdarea = wdarea.*grabl;
Awd = nansum(wdarea(:));

area75 = wdarea(HotPs==75);
A75 = nansum(area75(:));

area90 = wdarea(HotPs==90);
A90 = nansum(area90(:));

area95 = wdarea(HotPs==95);
A95 = nansum(area95(:));
%
Ahps = [A75,A90,A95];
hp = [75,90,95];
Prst = nan(3,6);
Trst = nan(3,6);
for x = 1:3
    idxP = find(HotPs==hp(x) & MetCt==-1);
    idxT = find(HotPs==hp(x) & MetCt==-2);
    
    Ptmp = PRP(idxP);
    Ttmp = TEM(idxT);
    NEEp = NEE(idxP);
    NEEt = NEE(idxT);
    Ap = wdarea(idxP);
    At = wdarea(idxT);
    
    Prst(x,1) = nanmean(NEEp);
    Prst(x,2) = nanmean(Ptmp);
    Prst(x,3) = nansum(Ap);
    Prst(x,4) = nansum(Ap)/Ahps(x);
    Prst(x,5) = nansum(Ap)/sum(Ahps);
    Prst(x,6) = nansum(Ap)/Awd;
    
    Trst(x,1) = nanmean(NEEt);
    Trst(x,2) = nanmean(Ttmp);
    Trst(x,3) = nansum(At);
    Trst(x,4) = nansum(At)/Ahps(x);
    Trst(x,5) = nansum(At)/sum(Ahps);
    Trst(x,6) = nansum(At)/Awd;
end

dlmwrite([outpt,'/PRP_hotspot.txt'],Prst,'delimiter',' ');
dlmwrite([outpt,'/TEM_hotspot.txt'],Trst,'delimiter',' ');

disp('Finish!')
