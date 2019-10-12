% Global and reginal flux and total NEE of Jung.
% The grids in both landcover datas of MTE and Jung.
% LINUX geotiff
% 2017.9.6
tic;close all;clear;clc

%%  input

NEEyflx_pt = '/home/test2/MTE_NEE/JungNEE/Flux/yearly';  % yearly NEE flux

Jg_Bthbl_fl = '/home/test2/MTE_NEE/JungNEE/BothGraGrid/new/Jung_GraPrc_both_12D_85.tif';
clmgs_fl = '/home/test2/MTE_NEE/OtherData/Gras_Clim.tif';  % climate of grassland

outpt = '/home/test2/MTE_NEE/JungNEE/Stat/Gra_both_sts/85prc';

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

grabl = double(imread(Jg_Bthbl_fl));
grabl(grabl==grabl(1,1)) = nan;

wdgra = wdarea.*grabl;

clmgs = double(imread(clmgs_fl));
clmgs(clmgs==clmgs(1,1)|isnan(grabl)) = nan;
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
        yf(isnan(grabl)) = nan;
        
        for clm = 1:length(uqclm)
            wdgra2 = wdgra(clmgs==uqclm(clm));
            yf1 = yf(clmgs==uqclm(clm));
            ytt1 = yf1.*wdgra2/1e9;  % Pg C
            ytt_rst(yr-yr1+1,clm) = nansum(ytt1);
            yflx_rst(yr-yr1+1,clm) = nansum(ytt1)*1e9/nansum(wdgra2(:));
        end
        ytt = yf(:).*wdgra(:)/1e9;  % Pg C
        ytt_rst(yr-yr1+1,clm+1) = nansum(ytt);
        yflx_rst(yr-yr1+1,clm+1) = nansum(ytt)*1e9/nansum(wdgra(:));
    end
    
    dlmwrite([outpt,'/JungNEE_bothGRA_tt_',dtstr{idt},'.txt',],...
        [[-999,uqclm',-999];[(yr1:yr2)',ytt_rst]],'delimiter',' ')
    dlmwrite([outpt,'/JungNEE_bothGRA_flx_',dtstr{idt},'.txt',],...
        [[-999,uqclm',-999];[(yr1:yr2)',yflx_rst]],'delimiter',' ')
end

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])
close all;clear
