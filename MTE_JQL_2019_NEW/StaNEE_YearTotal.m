% Yearly NEE total: PgC/yr
% 2017.3.25
clear;close all;clc;tic

%%  input

ras_pt = '/home/JiQiulei/MTE_JQL_2019/NEE_Upscale_NoIF_Sum2Year/Flux';
efrg = [-5000,10000];
sf = 1;

grabl_fl = '/home/JiQiulei/MTE_JQL_2019/glc2000_10km_grass_bili.tif';

bv = -9999;
outpt = '/home/JiQiulei/MTE_JQL_2019/NEE_Upscale_NoIF_Sum2Year/Total';

%% operate

S1 = referenceSphere('earth','km');
wdzone = ones(1752,4320);
Rmat = makerefmat('RasterSize',[1752 4320],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');
[~,colarea] = areamat(wdzone,Rmat,S1);
wdarea = repmat(colarea,1,4320);

grabl = double(imread(grabl_fl));
grabl(grabl==grabl(1,1)) = nan;

afs = dir([ras_pt,'/*.tif']);
for fl = 1:length(afs)
    ytmp = double(imread([ras_pt,'/',afs(fl).name]));
    ytmp(ytmp==ytmp(1,1)) = nan;
    ytmp = ytmp*sf.*wdarea.*grabl/10^9;
    ytmp(isnan(ytmp)) = bv;
    
    geotiffwrite([outpt,'/',afs(fl).name(1:end-4),'_total.tif'],single(ytmp),Rmat)
    disp(num2str(fl))
end

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])
