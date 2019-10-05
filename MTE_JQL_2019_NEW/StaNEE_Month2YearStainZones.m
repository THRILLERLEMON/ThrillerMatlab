% Statistics the NEE in Zones (Unit=Pg C/year)
% output Yearly sum NEE (Unit=g c/m2/year)
% Linux
% 2019.10.4
% JiQiulei thrillerlemon@outlook.com
clear;clc

%%%%%%%%%在这里修改年份
% yearSE=[2000,2011];
% yearSE=[1982,1989];
yearSE=[1982,2011];

NEEDataPath='/home/JiQiulei/MTE_JQL_2019/NEE_Upscale/';

GrassPer = imread('/home/JiQiulei/MTE_JQL_2019/glc2000_10km_grass_bili.tif');  % grass percentile
GrassPer(GrassPer==GrassPer(1,1)) = nan;
CliZones= imread('/home/JiQiulei/MTE_JQL_2019/grasslands_5climate_zones.tif');

outputPath='/home/JiQiulei/MTE_JQL_2019/NEE_Sta/';
outYearDataPath='/home/JiQiulei/MTE_JQL_2019/NEE_Upscale_Sum2Year/';

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


zoneALLsum=[];
zoneALLmean=[];
zone1sum=[];
zone1mean=[];
zone2sum=[];
zone2mean=[];
zone3sum=[];
zone3mean=[];
zone4sum=[];
zone4mean=[];
zone5sum=[];
zone5mean=[];

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

    zoneALLsum=[zoneALLsum;nansum(nansum(totalNEEYear))];
    zoneALLmean=[zoneALLmean;nanmean(nanmean(totalNEEYear))];

    zone1sum=[zone1sum;nansum(nansum(totalNEEYear(CliZones==1)))];
    zone1mean=[zone1mean;nanmean(nanmean(totalNEEYear(CliZones==1)))];
    zone2sum=[zone2sum;nansum(nansum(totalNEEYear(CliZones==2)))];
    zone2mean=[zone2mean;nanmean(nanmean(totalNEEYear(CliZones==2)))];
    zone3sum=[zone3sum;nansum(nansum(totalNEEYear(CliZones==3)))];
    zone3mean=[zone3mean;nanmean(nanmean(totalNEEYear(CliZones==3)))];
    zone4sum=[zone4sum;nansum(nansum(totalNEEYear(CliZones==4)))];
    zone4mean=[zone4mean;nanmean(nanmean(totalNEEYear(CliZones==4)))];
    zone5sum=[zone5sum;nansum(nansum(totalNEEYear(CliZones==5)))];
    zone5mean=[zone5mean;nanmean(nanmean(totalNEEYear(CliZones==5)))];

    % thisYearSum(isnan(thisYearSum)) = -9999; 
    % geotiffwrite([outYearDataPath,num2str(y),'NEEsum2Year_flux.tif'],thisYearSum,Rmat);
end



% zoneALLsum=squeeze(nansum(nansum(grassNEE,2),1));
% zoneALLmean=squeeze(nanmean(nanmean(grassNEE,2),1));

% yearSE=[1982,2011];
% colNamesGl=[];
% colNamesZ1=[];
% colNamesZ2=[];
% colNamesZ3=[];
% colNamesZ4=[];
% colNamesZ5=[];
% for yyy = yearSE(1):yearSE(2)
%     colNamesGl=[string(colNamesGl);string(['Global_',num2str(yyy)])];
%     colNamesZ1=[string(colNamesZ1);string(['Zone1_',num2str(yyy)])];
%     colNamesZ2=[string(colNamesZ2);string(['Zone2_',num2str(yyy)])];
%     colNamesZ3=[string(colNamesZ3);string(['Zone3_',num2str(yyy)])];
%     colNamesZ4=[string(colNamesZ4);string(['Zone4_',num2str(yyy)])];
%     colNamesZ5=[string(colNamesZ5);string(['Zone5_',num2str(yyy)])];
% end


% outGlobalData=[[[string('Zones'),string('YearsSum'),string('YearsMean')];...
% [colNamesGl,zoneALLsum,zoneALLmean]];...
% [colNamesZ1,zone1sum,zone1mean];...
% [colNamesZ2,zone2sum,zone2mean];...
% [colNamesZ3,zone3sum,zone3mean];...
% [colNamesZ4,zone4sum,zone4mean];...
% [colNamesZ5,zone5sum,zone5mean]];

% xlswrite('out.xls', cellstr(outGlobalData));

save([outputPath,num2str(yearSE(1)),'-',num2str(yearSE(2)),'StaNEE_Month2YearStainZones_EnvVar.mat'],'zoneALLsum','zoneALLmean','zone1sum','zone1mean','zone2sum','zone2mean','zone3sum','zone3mean','zone4sum','zone4mean','zone5sum','zone5mean');

disp('Finish!')

