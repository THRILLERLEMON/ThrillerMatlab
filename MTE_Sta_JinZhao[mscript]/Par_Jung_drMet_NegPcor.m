% The coefficient of partial correlation between Jung's NEE with PRP, TEM and SwSr.
% geotiff
% 2017.5.11
tic;clear;close all;clc

%%  Input

drMetpt = '/home/test2/MTE_NEE/MeteoData/DETREND';
outpt = '/home/test2/MTE_NEE/JungNEE/Pcor/drMet_neg';  % Outpath

%%  pm

NEE_pt = '/home/test2/MTE_NEE/JungNEE/Flux/yearly/RF';  % NEE flux yearly data path
NEE_vd = [-5000,30000];
outhd = 'RF';

TEM_pt = [drMetpt,'/Temperature'];  % TEM yearly data path
TEM_vd = [-1000,1000];

PRP_pt = [drMetpt,'/Precipitation'];  % PRP yearly data path
PRP_vd = [-30000,30000];

SWR_pt = [drMetpt,'/SWrad'];  % SWR yearly data path
SWR_vd = [-30000,30000];

clm_fl = '/home/test2/MTE_NEE/OtherData/Gras_Clim.tif';

sigp = 0.05;

%%  Operate

mkdir(outpt)

NEE_afs = dir([NEE_pt,'/*.tif']);
PRP_afs = dir([PRP_pt,'/*.tif']);
SWR_afs = dir([SWR_pt,'/*.tif']);
TEM_afs = dir([TEM_pt,'/*.tif']);

[m,n] = deal(1752,4320);
Rmat = makerefmat('RasterSize',[m n],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

clm = imread(clm_fl);
clm(clm==clm(1,1)) = nan;

NEE_dt = nan(m,n,length(NEE_afs));
PRP_dt = nan(m,n,length(NEE_afs));
SWR_dt = nan(m,n,length(NEE_afs));
TEM_dt = nan(m,n,length(NEE_afs));

disp('Reading...')
for fl = 1:length(NEE_afs)
    tmp1 = double(imread([NEE_pt,'/',NEE_afs(fl).name]));  % NEE
    tmp1(tmp1<NEE_vd(1) | tmp1>NEE_vd(2)) = nan;
    tmp1 = kron(tmp1,ones(6,6));
    tmp1 = tmp1(1:1752,:);
    tmp1(isnan(clm)) = nan;
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
    
    disp(num2str(fl))
end

rst_r = nan(m,n,3);  % PRP SWR TEM
rst_p = nan(m,n,3);
rst_rsig = nan(m,n,3);
rmin = nan(m,n,3);  % Rmin, Rsig min, Rmin sig

parobj=parpool('local',15);
disp('Calculating...')
parfor ir = 1:m
    r1 = nan(1,n,3);  % PRP SWR TEM
    p1 = nan(1,n,3);
    rsig1 = nan(1,n,3);
    rmin1 = nan(1,n,3);
    for ic = 1:n
        NEE = squeeze(NEE_dt(ir,ic,:));
        PRP = squeeze(PRP_dt(ir,ic,:));
        SWR = squeeze(SWR_dt(ir,ic,:));
        TEM = squeeze(TEM_dt(ir,ic,:));
        if all(~isnan(sum([NEE,PRP,SWR,TEM])))
            [r1(1,ic,1),p1(1,ic,1)] = partialcorr(NEE,PRP,[SWR,TEM]);  % PRP
            [r1(1,ic,2),p1(1,ic,2)] = partialcorr(NEE,SWR,[PRP,TEM]);  % SWR
            [r1(1,ic,3),p1(1,ic,3)] = partialcorr(NEE,TEM,[SWR,PRP]);  % TEM
            
            pvs = squeeze(p1(1,ic,:));
            pcors = squeeze(r1(1,ic,:));
            
            if all(~isnan([pvs;pcors]))
                idx = find(pcors==min(pcors));
                rmin1(1,ic,1) = idx*sign(pcors(idx));  % R min
                
                if pvs(idx)<=sigp
                    rmin1(1,ic,3) = idx*sign(pcors(idx));  % Rmin sig
                end
                pcors(pvs>sigp) = nan;
                if any(~isnan(pcors))
                    rsig1(1,ic,:) = pcors;
                    idx1 = find(pcors==min(pcors));
                    rmin1(1,ic,2) = idx1*sign(pcors(idx1));  % Rsig min
                end
            end
        end
    end
    rst_r(ir,:,:) = r1;
    rst_p(ir,:,:) = p1;
    rst_rsig(ir,:,:) = rsig1;
    rmin(ir,:,:) = rmin1;
    
    disp(num2str(ir))
end

rst_r(isnan(rst_r)) = -9999;
rst_p(isnan(rst_p)) = -9999;
rst_rsig(isnan(rst_rsig)) = -9999;
rmin(isnan(rmin)) = -9999;

vnm = {'PRP','SWR','TEM'};
for vr = 1:3
    geotiffwrite([outpt,'/JungGra_',outhd,'_',vnm{vr},'_pR.tif'],...
        single(rst_r(:,:,vr)),Rmat)
    geotiffwrite([outpt,'/JungGra_',outhd,'_',vnm{vr},'_pP.tif'],...
        single(rst_p(:,:,vr)),Rmat)
    geotiffwrite([outpt,'/JungGra_',outhd,'_',vnm{vr},'_pRsig.tif'],...
        single(rst_rsig(:,:,vr)),Rmat)
    
    disp(vnm{vr})
end

rstr = {'min','sig_min','min_sig'};
for irs = 1:3
    geotiffwrite([outpt,'/JungGra_pR_',outhd,'_',rstr{irs},'.tif'],...
        int8(rmin(:,:,irs)),Rmat)
end

delete(parobj);
mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])
