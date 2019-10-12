% Global and reginal flux and total NEE of Jung.
% Only grass grids used in MTE.
% LINUX geotiff
% 2017.9.4
tic;close all;clear;clc

%%  input

NEEyflx_pt = '/home/test2/MTE_NEE/JungNEE/Flux/yearly';  % yearly NEE total

grabl_fl = '/home/test2/MTE_NEE/OtherData/glc2000_10km_grass_bili.tif';
clmgs_fl = '/home/test2/MTE_NEE/OtherData/Gras_Clim.tif';  % climate of grassland

outpt = '/home/test2/MTE_NEE/JungNEE/Stat/Gra_MTEonly_sts';

%%  operate

[yr1,yr2] = deal(1982,2011);

dtstr = {'ANN','MARS','RF'};
hds = 'CRUNCEPv6.';
fts = '.tif';

[nrw,ncl] = deal(1752,4320);
S1 = referenceSphere('earth','km');
wdzone = ones(nrw,ncl);
Rmat = makerefmat('RasterSize',[nrw ncl],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');
[~,colarea] = areamat(wdzone,Rmat,S1);
wdarea = repmat(colarea,1,ncl);

grabl = double(imread(grabl_fl));
grabl(grabl==grabl(1,1)) = nan;

wdgra = wdarea.*grabl;

clmgs = double(imread(clmgs_fl));
clmgs(clmgs==clmgs(1,1)) = nan;
clmgs2 = clmgs(:);
clmgs2(isnan(clmgs2)) = [];
uqclm = unique(clmgs2(:));

disp('start')
for idt = 1:length(dtstr)
    disp(dtstr{idt})
    
    yf_hd = [hds,dtstr{idt},'.NEE.annual.'];
    
    ytt_rst = nan(yr2-yr1+1,length(uqclm)+1);
    yflx_rst = nan(yr2-yr1+1,length(uqclm)+1);
    for yr = yr1:yr2
        disp(num2str(yr))
        
        yf = double(imread([NEEyflx_pt,'/',dtstr{idt},'/',yf_hd,...
            num2str(yr),fts]));
        yf(yf==yf(1,1)) = nan;
        yf = yf(1:292,:);
        yf = kron(yf,ones(6,6));
        
        wdarea1 = wdgra;
        yf(isnan(wdarea1)) = nan;
        wdarea1(isnan(yf)) = nan;
        for clm = 1:length(uqclm)
            wdarea2 = wdarea1(clmgs==uqclm(clm));
            yf1 = yf(clmgs==uqclm(clm));
            ytt1 = yf1.*wdarea2/10^9;  % PgC/season
            ytt_rst(yr-yr1+1,clm) = nansum(ytt1);
            yflx_rst(yr-yr1+1,clm) = nansum(ytt1)*10^9/nansum(wdarea2(:));
        end
        ytt = yf(:).*wdarea1(:)/10^9;  % PgC/season
        ytt_rst(yr-yr1+1,clm+1) = nansum(ytt);
        yflx_rst(yr-yr1+1,clm+1) = nansum(ytt)*10^9/nansum(wdarea1(:));
    end
    
    dlmwrite([outpt,'/NEE_MTEonlyGRA_tt_',dtstr{idt},'.txt',],...
        [(yr1:yr2)',ytt_rst],'delimiter',' ')
    dlmwrite([outpt,'/NEE_MTEonlyGRA_flx_',dtstr{idt},'.txt',],...
        [(yr1:yr2)',yflx_rst],'delimiter',' ')
end

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])

