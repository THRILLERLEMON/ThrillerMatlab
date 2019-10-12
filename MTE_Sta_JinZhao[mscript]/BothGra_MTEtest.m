% test both grass
% geotiff
% 2017.5.9
clear;close all;clc

%%  input

NEEfm_pt = '/home/test2/MTE_NEE/NEE_new02/yflux';
GrapcM_fl = '/home/test2/MTE_NEE/OtherData/glc2000_10km_grass_bili.tif';

Bgra_fl = '/home/test2/MTE_NEE/JungNEE/BothGraGrid/MTE_BothGra85.tif';

outpt = '/home/test2/MTE_NEE/JungNEE/BothGraGrid';

%%  operate

Bgra = double(imread(Bgra_fl));
Bgra(Bgra==Bgra(1,1)) = nan;

S1 = referenceSphere('earth','km');
wdzone = ones(1752,4320);
RmatM = makerefmat('RasterSize',[1752 4320],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');
[~,colarea] = areamat(wdzone,RmatM,S1);
wdaM = repmat(colarea,1,4320);

%
yrs = [1982,2011];
rst = nan(yrs(2)-yrs(1)+1,1);  % MTE
for yr = yrs(1):yrs(2)
    MTE = double(imread([NEEfm_pt,'/NEEgra_FluxSum_',...
        num2str(yr),'_01to12.tif']));
    MTE(MTE==MTE(1,1)) = nan;
    MTE(isnan(Bgra)) = nan;
    MTE = MTE.*wdaM;
    wdaM2 = wdaM;
    wdaM2(isnan(MTE)) = nan;
    rst(yr-yrs(1)+1,1) = nansum(MTE(:))/nansum(wdaM2(:));
    
    disp(num2str(yr))
end

dlmwrite([outpt,'/MTE_GGrids_85.txt'],rst,'delimiter',' ')

disp('Finish!')
