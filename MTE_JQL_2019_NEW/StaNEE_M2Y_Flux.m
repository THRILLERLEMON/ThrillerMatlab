% Monthly NEE density to yearly
% output Yearly sum NEE (Unit=g c/m2/year)
% Linux
% 2019.10.4
% JiQiulei thrillerlemon@outlook.com
clear;close all;clc;tic


NEEm_pt = '/home/JiQiulei/MTE_JQL_2019/NEE_Upscale_IFisZERO';

ygap = [1982,2011];
mgap = [1,12];
efrg = [-5000,10000];
sf = 1;
hds = '';
fts = '_global_grass_NEE_NoIF_MTEmean.tif';

outhds = 'NoIF_FluxSum';
outpt = '/home/JiQiulei/MTE_JQL_2019/NEE_Upscale_NoIF_Sum2Year/Flux';

%%  operate

Rmat = makerefmat('RasterSize',[1752 4320],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');
nrow = 1752;
ncol = 4320;

efrg1 = efrg(1);
efrg2 = efrg(2);
mgp1 = mgap(1);
mgp2 = mgap(2);

parobj = parpool('local',15);
parfor yr = ygap(1):ygap(2)
    ytmp = zeros(nrow,ncol);
    idx = zeros(nrow,ncol);
    for mth = mgp1:mgp2
        mtmp = double(imread([NEEm_pt,'/',...
            hds,num2str(yr),num2str(mth,'%02d'),fts]));
        mtmp(mtmp==mtmp(1,1)) = nan;
        mtmp = mtmp*sf;
        ytmp = nansum(cat(3,ytmp,mtmp),3);  %%%
        idx = sum(cat(3,idx,~isnan(mtmp)),3);
    end
    ytmp(idx==0) = nan;
    ytmp(isnan(ytmp)) = -9999;
    geotiffwrite([outpt,'/',outhds,'_',num2str(yr),'_',...
        num2str(mgp1,'%02d'),'to',num2str(mgp2,'%02d'),'.tif'],single(ytmp),Rmat)
    disp(num2str(yr))
end
delete(parobj);

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])

