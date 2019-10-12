% Global and reginal flux and total NEE of Jung.
% The grids in both landcover datas of MTE and Jung.
% LINUX geotiff
% 2017.9.8
clear;close all;clc;tic

%%  Input

NEEysm_pt = '/home/test2/MTE_NEE/NEE_new02/ytotal';  % yearly NEE total

MTE_Bthbl_fl = '/home/test2/MTE_NEE/JungNEE/BothGraGrid/new/MTE_GraPrc_both_12D_85.tif';
clmgs_fl = '/home/test2/MTE_NEE/OtherData/Gras_Clim.tif';  % climate of grassland

outpt = '/home/test2/MTE_NEE/NEE_new02/Stat/Gra_both_sts/85prc';

%%  Operate

yt_hd = 'NEEgra_FluxSum_';
yt_ft = '_01to12_total.tif';

sn_hd = 'NEEgra_TotalSum';
sn_ft = '_sum.tif';

disp('clm')

[nrw,ncl] = deal(1752,4320);
S1 = referenceSphere('earth','km');
wdzone = ones(nrw,ncl);
Rmat = makerefmat('RasterSize',[nrw ncl],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');
[~,colarea] = areamat(wdzone,Rmat,S1);
wdarea = repmat(colarea,1,ncl);

grabl = double(imread(MTE_Bthbl_fl));
grabl(grabl==grabl(1,1)) = nan;

wdgra = wdarea.*grabl;

clmgs = double(imread(clmgs_fl));
clmgs(clmgs==clmgs(1,1)|isnan(grabl)) = nan;
clmgs2 = clmgs(:);
clmgs2(isnan(clmgs2)) = [];
uqclm = unique(clmgs2(:));
clearvars clmgs2

[yr1,yr2] = deal(1982,2011);
yrst = nan(yr2-yr1+1,length(uqclm)+1,2);
disp('start')
for yr = yr1:yr2
    ytt = double(imread([NEEysm_pt,'/',yt_hd,...
        num2str(yr),yt_ft]));
    ytt(ytt==ytt(1,1)|isnan(grabl)) = nan;
    
    for clm = 1:length(uqclm)
        wdgra2 = wdgra(clmgs==uqclm(clm));
        ytt1 = ytt(clmgs==uqclm(clm));
        
        yrst(yr-yr1+1,clm,1) = nansum(ytt1);  % Pg C
        yrst(yr-yr1+1,clm,2) = nansum(ytt1)*1e9/(nansum(wdgra2));
    end
    yrst(yr-yr1+1,end,1) = nansum(ytt(:));
    yrst(yr-yr1+1,end,2) = nansum(ytt(:))*1e9/(nansum(wdgra(:)));
    
    disp(num2str(yr))
end

disp('write')
dlmwrite([outpt,'/MTENEE_bothGRA_tt.txt'],...
    [[-999,uqclm',-999];[(yr1:yr2)',yrst(:,:,1)]],'delimiter',' ')
dlmwrite([outpt,'/MTENEE_bothGRA_flx.txt'],...
    [[-999,uqclm',-999];[(yr1:yr2)',yrst(:,:,2)]],'delimiter',' ')

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])
close all;clear

