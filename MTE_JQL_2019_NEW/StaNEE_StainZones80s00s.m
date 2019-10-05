% Statistics the NEE in Zones (Unit=Pg C/year)
% Linux
% 2019.10.4
% JiQiulei thrillerlemon@outlook.com
clear;clc

%%  input
%%%%%%%%%在这里修改年份
% yearSE=[2000,2011];
yearSE=[1982,1989];

NEEDataPath='/home/JiQiulei/MTE_JQL_2019/NEE_Upscale/';

GrassPer = imread('/home/JiQiulei/MTE_JQL_2019/glc2000_10km_grass_bili.tif');  % grass percentile
GrassPer(GrassPer==GrassPer(1,1)) = nan;
CliZones= imread('/home/JiQiulei/MTE_JQL_2019/grasslands_5climate_zones.tif');

outputPath='/home/JiQiulei/MTE_JQL_2019/NEE_Sta/';

%%  operate
gridSizze=1/12;
nrows = 1752;
ncols = 4320;
lats = [-56,90];
lons = [-180,180];
wdzone = ones(nrows,ncols);
Rmat = makerefmat('RasterSize',[nrows,ncols],...
    'Latlim',[lats(1) lats(2)], 'Lonlim',[lons(1) lons(2)],...
    'ColumnsStartFrom','north');
S1 = referenceSphere('earth','km');
[~,colarea] = areamat(wdzone,Rmat,S1);
wdarea = repmat(colarea,1,ncols);

grassNEE = NaN(1752,4320,yearSE(1)-yearSE(2)+1);
for y = yearSE(1):yearSE(2)
    monthData=NaN(1752,4320,12);
    for m = 1:12
        monthNEE=imread([NEEDataPath,num2str(y),num2str(m,'%02d'),'_global_grass_NEE_MTEmean.tif']);
        monthNEE(monthNEE==monthNEE(1,1)) = nan;
        monthData(:,:,m)=monthNEE;
    end
    thisYearSum=nansum(monthData,3);
    totalNEEYear = thisYearSum.*repmat(wdarea,1,1,size(thisYearSum,3)).*repmat(GrassPer,1,1,size(thisYearSum,3))/10^9;  % PgC/year
    grassNEE(:,:,y-yearSE(1)+1)=totalNEEYear;
end



zoneALLsum=squeeze(nansum(nansum(grassNEE,2),1));
zoneALLmean=squeeze(nanmean(nanmean(grassNEE,2),1));

zone1NEE=grassNEE(CliZones==1);
zone1sum=squeeze(nansum(nansum(zone1NEE,2),1));
zone2NEE=grassNEE(CliZones==2);
zone2sum=squeeze(nansum(nansum(zone1NEE,2),1));
zone3NEE=grassNEE(CliZones==3);
zone3sum=squeeze(nansum(nansum(zone1NEE,2),1));
zone4NEE=grassNEE(CliZones==4);
zone4sum=squeeze(nansum(nansum(zone1NEE,2),1));
zone5NEE=grassNEE(CliZones==5);
zone5sum=squeeze(nansum(nansum(zone1NEE,2),1));


zone1mean=squeeze(nanmean(nanmean(zone1NEE,2),1));
zone2mean=squeeze(nanmean(nanmean(zone1NEE,2),1));
zone3mean=squeeze(nanmean(nanmean(zone1NEE,2),1));
zone4mean=squeeze(nanmean(nanmean(zone1NEE,2),1));
zone5mean=squeeze(nanmean(nanmean(zone1NEE,2),1));

outData=[
[string('Zones'),string('YearsSum'),string('YearsMean')];
[string('Global'),zoneALLsum,zoneALLmean];
[string('Zone1'),zone1sum,zone1mean];
[string('Zone2'),zone2sum,zone2mean];
[string('Zone3'),zone3sum,zone3mean];
[string('Zone4'),zone4sum,zone4mean];
[string('Zone5'),zone5sum,zone5mean];];


dlmwrite(outputPath,num2str(yearSE(1)),'-',num2str(yearSE(1)),'StaNEEinZones_NEEsum2Years_flux.txt',outData);

disp('Finish!')
