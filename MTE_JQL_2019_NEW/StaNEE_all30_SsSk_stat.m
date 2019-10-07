% Calculate the area, grids number and sum of NEE total.
% geotiff
% 2017.5.12
clear;close all;clc

%%  input

NEEtt_fl = '/home/JiQiulei/MTE_JQL_2019/NEE_Sta/NEETotal_1982-2011_mean.tif';

grapc_fl = '/home/test2/MTE_NEE/OtherData/glc2000_10km_grass_bili.tif';

pynum_fl = '/home/JiQiulei/MTE_JQL_2019/NEE_Sta/NEEgra_1982to2011_psYnum.tif';
nynum_fl = '/home/JiQiulei/MTE_JQL_2019/NEE_Sta/NEEgra_1982to2011_ngYnum.tif';

NEEslp_fl = '/home/JiQiulei/MTE_JQL_2019/NEE_Sta/NEEgraFlx_82to11_slope.tif';

hotps_fl = '/home/JiQiulei/MTE_JQL_2019/NEE_Sta/NEE_YearTotal_82to11_Hotspots.tif';
outpt = '/home/JiQiulei/MTE_JQL_2019/NEE_Sta';

%%  operate

NEEtt = double(imread(NEEtt_fl));
NEEtt(NEEtt==NEEtt(1,1)) = nan;
NEEtt = NEEtt(:);

pynm = double(imread(pynum_fl));
pynm(pynm==pynm(1,1))=nan;
nynm = double(imread(nynum_fl));
nynm(nynm==nynm(1,1))=nan;

NEEslp = double(imread(NEEslp_fl));
NEEslp(NEEslp==NEEslp(1,1))=nan;

hotps = imread(hotps_fl);
hotps(hotps==hotps(1,1)) = nan;
hotps = hotps(:);

grapc = double(imread(grapc_fl));
grapc(grapc==grapc(1,1)) = nan;

S1 = referenceSphere('earth','km');
wdzone = ones(1752,4320);
Rmat = makerefmat('RasterSize',[1752 4320],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');
[~,colarea] = areamat(wdzone,Rmat,S1);
wdarea = repmat(colarea,1,4320);

GraArea = wdarea.*grapc;
GraArea = GraArea(:);

rst30 = nan(2,3);  % area area% sum
rst30(1,1) = sum(GraArea(pynm==30));
rst30(1,2) = sum(GraArea(pynm==30))/nansum(GraArea);
rst30(1,3) = sum(NEEtt(pynm==30));

rst30(2,1) = sum(GraArea(nynm==30));
rst30(2,2) = sum(GraArea(nynm==30))/nansum(GraArea);
rst30(2,3) = sum(NEEtt(nynm==30));

rstsk = nan(2,3);
rstsk(1,1) = sum(GraArea(pynm==30 & NEEslp>0));
rstsk(1,2) = sum(GraArea(pynm==30 & NEEslp>0))/nansum(GraArea);
rstsk(1,3) = sum(NEEtt(pynm==30 & NEEslp>0));

rstsk(2,1) = sum(GraArea(nynm==30 & NEEslp<0));
rstsk(2,2) = sum(GraArea(nynm==30 & NEEslp<0))/nansum(GraArea);
rstsk(2,3) = sum(NEEtt(nynm==30 & NEEslp<0));

hp = [75,90,95];
rsthp = nan(3,4);
for x = 1:3
    rsthp(x,1) = sum(GraArea(hotps==hp(x)));
    rsthp(x,2) = sum(GraArea(hotps==hp(x)))/nansum(GraArea);
    rsthp(x,3) = sum(NEEtt(hotps==hp(x) & NEEtt>0));
    rsthp(x,4) = sum(NEEtt(hotps==hp(x) & NEEtt<0));
end

dlmwrite([outpt,'/NEE_ALL30_stat.txt'],rst30,'delimiter',' ')
dlmwrite([outpt,'/NEE_AmpSsSk_stat.txt'],rstsk,'delimiter',' ')
dlmwrite([outpt,'/NEE_hotpots_stat.txt'],rsthp,'delimiter',' ')

disp('Finish!')

