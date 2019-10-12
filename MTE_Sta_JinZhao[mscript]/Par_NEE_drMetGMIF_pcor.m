% The coefficient of partial correlation between NEE with PRP, TEM and SwSr.
% geotiff
% 2017.3.31
tic;clear;close all;clc

%%  Input

drMetpt = '/home/test2/MTE_NEE/MeteoData/DETREND';
outpt = '/home/test2/MTE_NEE/NEE_year/Pcor/no0';  % Outpath

%%  pm

NEE_pt = '/home/test2/MTE_NEE/NEE_year/yflux/all';  % NEE flux yearly data path
NEE_vd = [-30000,30000];

TEM_pt = [drMetpt,'/Temperature'];  % TEM yearly data path
TEM_vd = [-1000,1000];

PRP_pt = [drMetpt,'/Precipitation'];  % PRP yearly data path
PRP_vd = [-30000,30000];

SWR_pt = [drMetpt,'/SWrad'];  % SWR yearly data path
SWR_vd = [-30000,30000];

GMIF_pt = '/home/test2/MTE_NEE/MeteoData/DETREND/IntensityFrac_no0';
GMIF_vd = [-10000,10000];

sigp = 0.05;

%%  Operate

mkdir(outpt)

NEE_afs = dir([NEE_pt,'/*.tif']);
PRP_afs = dir([PRP_pt,'/*.tif']);
SWR_afs = dir([SWR_pt,'/*.tif']);
TEM_afs = dir([TEM_pt,'/*.tif']);
GMIF_afs = dir([GMIF_pt,'/*.tif']);

[m,n] = deal(1752,4320);
Rmat = makerefmat('RasterSize',[m n],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

NEE_dt = nan(m,n,length(NEE_afs));
PRP_dt = nan(m,n,length(PRP_afs));
SWR_dt = nan(m,n,length(SWR_afs));
TEM_dt = nan(m,n,length(TEM_afs));
GMIF_dt = nan(m,n,length(GMIF_afs));

disp('Reading...')
for fl = 1:length(NEE_afs)
    tmp1 = double(imread([NEE_pt,'/',NEE_afs(fl).name]));  % NEE
    tmp1(tmp1<NEE_vd(1) | tmp1>NEE_vd(2)) = nan;
    NEE_dt(:,:,fl) = tmp1;
    
    tmp2 = double(imread([PRP_pt,'/',PRP_afs(fl).name]));  % PRP
    tmp2(tmp2<PRP_vd(1) | tmp2>PRP_vd(2)) = nan;
    PRP_dt(:,:,fl) = tmp2;
    
    tmp3 = double(imread([SWR_pt,'/',SWR_afs(fl).name]));  % SWR
    tmp3(tmp3<SWR_vd(1) | tmp3>SWR_vd(2)) = nan;
    SWR_dt(:,:,fl) = tmp3;
    
    tmp4 = double(imread([TEM_pt,'/',TEM_afs(fl).name]));  % TEM
    tmp4(tmp4<TEM_vd(1) | tmp4>TEM_vd(2)) = nan;
    TEM_dt(:,:,fl) = tmp4;
    
    tmp5 = double(imread([GMIF_pt,'/',GMIF_afs(fl).name]));  % GMIF
    tmp5(tmp5<GMIF_vd(1) | tmp5>GMIF_vd(2)) = nan;
    GMIF_dt(:,:,fl) = tmp5;
    
    disp(num2str(fl))
end

rst_r = nan(m,n,4);  % PRP SWR TEM GMIF
rst_p = nan(m,n,4);
rst_rsig = nan(m,n,4);
rmax = nan(m,n,4);  % Rmax, Rmax >others, Rmax sig, Rmax >others & sig

parobj=parpool('local',16);
disp('Calculating...')
parfor ir = 1:m
    r1 = nan(1,n,4);  % PRP SWR TEM GMIF
    p1 = nan(1,n,4);
    rsig1 = nan(1,n,4);
    rmax1 = nan(1,n,4);
    for ic = 1:n
        NEE = squeeze(NEE_dt(ir,ic,:));
        PRP = squeeze(PRP_dt(ir,ic,:));
        SWR = squeeze(SWR_dt(ir,ic,:));
        TEM = squeeze(TEM_dt(ir,ic,:));
        GMIF = squeeze(GMIF_dt(ir,ic,:));
        if all(~isnan(sum([NEE,PRP,SWR,TEM,GMIF])))
            [r1(1,ic,1),p1(1,ic,1)] = partialcorr(NEE,PRP,[SWR,TEM,GMIF]);  % PRP
            [r1(1,ic,2),p1(1,ic,2)] = partialcorr(NEE,SWR,[PRP,TEM,GMIF]);  % SWR
            [r1(1,ic,3),p1(1,ic,3)] = partialcorr(NEE,TEM,[SWR,PRP,GMIF]);  % TEM
            [r1(1,ic,4),p1(1,ic,4)] = partialcorr(NEE,GMIF,[SWR,PRP,TEM]);  % GMIF
            
            pvs = squeeze(p1(1,ic,:));
            pcors = squeeze(r1(1,ic,:));
            
            if all(~isnan([pvs;pcors]))
                idx = find(abs(pcors)==max(abs(pcors)));
                rmax1(1,ic,1) = idx*sign(pcors(idx));  % R max
                if abs(pcors(idx))>sum(abs(pcors))-abs(pcors(idx))
                    rmax1(1,ic,2) = idx*sign(pcors(idx));  % R max >others
                    if pvs(idx) < sigp
                        rmax1(1,ic,4) = idx*sign(pcors(idx));  % R max >others & sig
                    end
                end
                
                
                pcors(pvs>sigp) = nan;
                if any(~isnan(pcors))
                    rsig1(1,ic,:) = pcors;
                    idx = find(abs(pcors)==max(abs(pcors)));
                    rmax1(1,ic,3) = idx*sign(pcors(idx));  % R max sig
                end
            end
%             disp(num2str(ic))
        end
    end
    rst_r(ir,:,:) = r1;
    rst_p(ir,:,:) = p1;
    rst_rsig(ir,:,:) = rsig1;
    rmax(ir,:,:) = rmax1;
    
    disp(num2str(ir))
end

rst_r(isnan(rst_r)) = -9999;
rst_p(isnan(rst_p)) = -9999;
rst_rsig(isnan(rst_rsig)) = -9999;
rmax(isnan(rmax)) = -9999;

vnm = {'PRP','SWR','TEM','GMIF'};
for vr = 1:4
    geotiffwrite([outpt,'/NEEgraFluxSum_',vnm{vr},'_pR.tif'],...
        rst_r(:,:,vr),Rmat)
    geotiffwrite([outpt,'/NEEgraFluxSum_',vnm{vr},'_pP.tif'],...
        rst_p(:,:,vr),Rmat)
    geotiffwrite([outpt,'/NEEgraFluxSum_',vnm{vr},'_pRsig.tif'],...
        rst_rsig(:,:,vr),Rmat)
    
    disp(vnm{vr})
end

rstr = {'org','big','sig','bigsig'};
for irs = 1:4
    geotiffwrite([outpt,'/NEEgraFluxSum_pRmax_',rstr{irs},'.tif'],...
        rmax(:,:,irs),Rmat)
end

delete(parobj);
mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])

