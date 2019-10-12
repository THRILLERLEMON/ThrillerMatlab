% Global NEE total and flux.
% geotiff
% 2017.5.3
clear;close all;clc;tic

%%  Input

NEEytt_pt = '/home/test2/MTE_NEE/JungNEE/Total/yearly';  % yearly NEE total

NEEsnytt = '/home/test2/MTE_NEE/JungNEE/Season';  % seasonal NEE

MODvg_fl = '/home/test2/MTE_NEE/JungNEE/clm/MCD12C1.IGBP2000.tif';  % MCD12C1

outpt = '/home/test2/MTE_NEE/JungNEE/Stat/Gra_MTE_sts';

%%  Operate

[yr1,yr2] = deal(1982,2011);
dtstr = {'ANN','MARS','RF'};
snstr = {'MAM','JJA','SON','DJF'};

hds = 'CRUNCEPv6.';
fts = '_ttsum.tif';

[nrw,ncl] = deal(360,720);
S1 = referenceSphere('earth','km');
wdzone = ones(nrw,ncl);
Rmat = makerefmat('RasterSize',[nrw ncl],...
    'Latlim',[-90 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');
[~,colarea] = areamat(wdzone,Rmat,S1);
wdarea = repmat(colarea,1,ncl);

[m,n] = deal(3600,7200);
wdzone05 = ones(m,n);
Rmat05 = makerefmat('RasterSize',[m n],...
    'Latlim',[-90 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');
[~,colarea05] = areamat(wdzone05,Rmat05,S1);
wdarea05 = repmat(colarea05,1,n);

MODvg = double(imread(MODvg_fl));
MODvg(MODvg==MODvg(1,1)) = nan;
MODvg1 = nan(360,720);

wdarea05(isnan(MODvg)) = nan;
for ir = 1:360
    for ic = 1:720
        tmp = MODvg(1+(ir-1)*10:ir*10,1+(ic-1)*10:ic*10);
        if any(~isnan(tmp(:)))
            atmp = wdarea05(1+(ir-1)*10:ir*10,1+(ic-1)*10:ic*10);
            gtmp = atmp;
            % gtmp(tmp~=10) = nan;
            gtmp(~(tmp==10|tmp==7|tmp==9)) = nan;  % 10.Grasslands 7.Open shrublands 9.Savannas
            MODvg1(ir,ic) = nansum(gtmp(:))*100/nansum(atmp(:));  % grass
        end
    end
end
gidx = find(MODvg1>=85);  %  grass percent
gpct = MODvg1(gidx)/100;
MODvg1(isnan(MODvg1)) = -9999;
geotiffwrite([outpt,'/MCD12C1_GraPrc.tif'],single(MODvg1),Rmat)

disp('start')
for idt = 1:length(dtstr)
    disp(dtstr{idt})
    
    yt_hd = [hds,dtstr{idt}];
    sn_hd = [dtstr{idt},'.NEE'];
    
    ytt_rst = nan(yr2-yr1+1,5);
    yflx_rst = nan(yr2-yr1+1,5);
    gytt_rst = nan(yr2-yr1+1,5);
    gyflx_rst = nan(yr2-yr1+1,5);
    
    for yr = yr1:yr2
        disp(num2str(yr))
        
        ytt = double(imread([NEEytt_pt,'/',dtstr{idt},'/',yt_hd,...
            num2str(yr),fts]));
        ytt(ytt==ytt(1,1)) = nan;
        
        wdarea1 = wdarea;
        wdarea1(isnan(ytt)) = nan;
        ytt_rst(yr-yr1+1,5) = nansum(ytt(:));
        yflx_rst(yr-yr1+1,5) = nansum(ytt(:))*10^9/nansum(wdarea1(:));
        
        ytt = ytt(gidx).*gpct;
        wdarea1 = wdarea1(gidx).*gpct;
        gytt_rst(yr-yr1+1,5) = nansum(ytt);
        gyflx_rst(yr-yr1+1,5) = nansum(ytt)*10^9/nansum(wdarea1);
        
        for isn = 1:3+(yr~=yr2)
            sntmp = double(imread([NEEsnytt,'/',sn_hd,'/SN_total/',...
                snstr{isn},'/',[hds,sn_hd],num2str(yr),'_',snstr{isn},fts]));
            sntmp(sntmp==sntmp(1,1)) = nan;
            
            wdarea1 = wdarea;
            wdarea1(isnan(sntmp)) = nan;
            ytt_rst(yr-yr1+1,isn) = nansum(sntmp(:));
            yflx_rst(yr-yr1+1,isn) = nansum(sntmp(:))*10^9/nansum(wdarea1(:));
            
            sntmp = sntmp(gidx).*gpct;
            wdarea1 = wdarea1(gidx).*gpct;
            gytt_rst(yr-yr1+1,isn) = nansum(sntmp);
            gyflx_rst(yr-yr1+1,isn) = nansum(sntmp)*10^9/nansum(wdarea1);
            
            disp(snstr{isn})
        end
    end
    
    dlmwrite([outpt,'/NEEtt_',dtstr{idt},'.txt',],...
        [(yr1:yr2)',ytt_rst],'delimiter',' ')
    dlmwrite([outpt,'/NEEflx_',dtstr{idt},'.txt',],...
        [(yr1:yr2)',yflx_rst],'delimiter',' ')
    dlmwrite([outpt,'/NEEgtt_',dtstr{idt},'.txt',],...
        [(yr1:yr2)',gytt_rst],'delimiter',' ')
    dlmwrite([outpt,'/NEEgflx_',dtstr{idt},'.txt',],...
        [(yr1:yr2)',gyflx_rst],'delimiter',' ')
end

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])

