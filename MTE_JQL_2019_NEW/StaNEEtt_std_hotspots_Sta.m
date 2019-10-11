% Count the area and mean NEE in different Hotpot levels.
% geotiff
% 2017.5.16
clear;close all;clc

%%  input

NEE_fl = '/home/JiQiulei/MTE_JQL_2019/NEE_Sta/NEETotal_1982-2011_mean.tif';

HotPs_fl = '/home/JiQiulei/MTE_JQL_2019/NEE_Sta/NEE_YearTotal_82to11_Hotspots.tif';
grabl_fl = '/home/test2/MTE_NEE/OtherData/glc2000_10km_grass_bili.tif';

outpt = '/home/JiQiulei/MTE_JQL_2019/NEE_Sta';

%%  operate

NEE = double(imread(NEE_fl));
NEE(NEE==NEE(1,1)) = nan;
NEEsign=sign(NEE);


HotPs = double(imread(HotPs_fl));
HotPs(HotPs==HotPs(1,1)) = nan;


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
Res = nan(3,9);
for x = 1:3
    idxP = find(HotPs==hp(x) & NEEsign==1);
    idxN = find(HotPs==hp(x) & NEEsign==-1);
    
    NEEP = NEE(idxP);
    AP = wdarea(idxP);
    NEEN = NEE(idxN);
    AN = wdarea(idxN);
    
    Res(x,1) = nansum(NEEP);
    Res(x,2) = nansum(NEEN);
    Res(x,3) = nansum(NEEP)+nansum(NEEN);
    Res(x,4) = (nansum(AP)+nansum(AN))/Awd;
    Res(x,5) = (nansum(AP)+nansum(AN));
    Res(x,6) = A75;
    Res(x,7) = A90;
    Res(x,8) = A95;
    Res(x,9) = Awd;
    
end

dlmwrite([outpt,'/Sta_hotspot.txt'],Res,'delimiter',' ');

disp('Finish!')
