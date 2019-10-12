% Calculate the correlation coefficient between PRP and NEE postponed for 0 to 4 months.
% geotiff
% 2017.4.12
tic;clear;close all;clc

%%  input

NEEflux_pt = '/home/test2/MTE_NEE/NEE_new/month';
neehds = '';
neefts = '_global_grass_NEE.tif';

PRP_pt = '/home/datastore/source/raster/Params/Pre/Global/198201_201112_CRU-3.22-0.5D';
prphds = 'CRU-TS3.22_PRE_';
prpfts = '.tif';

outpt = '/home/test2/MTE_NEE/NEE_new/Month_Lag';

[yr1,yr2] = deal(1982,2011);
[mn1,mn2] = deal(1,12);
[mlg1,mlg2] = deal(0,4);  % number of months lagged
sigp = 0.05;
bv = -9999;

%%  operate

[m,n] = deal(1752,4320);
Rmat = makerefmat('RasterSize',[m n],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

NEEmndt = nan(m,n,(yr2-yr1+1)*(mn2-mn1+1));
PRPmndt = nan(m,n,(yr2-yr1+1)*(mn2-mn1+1));
disp('Reading:')
ipg = 1;
for yr = yr1:yr2
    disp(num2str(yr))
    for mn = mn1:mn2
        NEE = double(imread([NEEflux_pt,'/',neehds,...
            num2str(yr),num2str(mn,'%02d'),neefts]));
        NEE(NEE==NEE(1,1)) = nan;
        NEEmndt(:,:,ipg) = NEE;
        
        PRP = double(imread([PRP_pt,'/',prphds,...
            num2str(yr),num2str(mn,'%02d'),prpfts]));
        PRP(PRP==PRP(1,1)) = nan;
        PRP = PRP(1:292,:);
        PRP = kron(PRP,ones(6,6));
        PRPmndt(:,:,ipg) = PRP;
        
        ipg = ipg+1;
        disp(num2str(mn))
    end
end

corrst = nan(m,n,5);  % R
pvrst = nan(m,n,5);  % P
corsigrst = nan(m,n,5);  % R-sig

parobj=parpool('local',15);
for mlg = mlg1:mlg2
    NEEmns = NEEmndt(:,:,1+mlg:end);
    PRPmns = PRPmndt(:,:,1:end-mlg);
    
    corrst1 = nan(m,n);
    pvrst1 = nan(m,n);
    corsigrst1 = nan(m,n);
    parfor ir = 1:m
        for ic = 1:n
            NEEm = squeeze(NEEmns(ir,ic,:));
            PRPm = squeeze(PRPmns(ir,ic,:));
            if all(~isnan([NEEm;PRPm]))
                [cor,pv] = corrcoef(NEEm,PRPm);
                corrst1(ir,ic) = cor(2,1);
                pvrst1(ir,ic) = pv(2,1);
                if pv(2,1)<=sigp
                    corsigrst1(ir,ic) = cor(2,1);
                end
            end
        end
    end
    corrst(:,:,mlg+1) = corrst1;
    pvrst(:,:,mlg+1) = pvrst1;
    corsigrst(:,:,mlg+1) = corsigrst1;
    
    disp(['lag:',num2str(mlg)])
end
clearvars NEEmndt PRPmndt NEEmns PRPmns

cormin = nan(m,n);  % R-min
corminsg = nan(m,n);  % Rmin-sig
lgmn = nan(m,n);  %  lag-month
parfor ir = 1:m
    for ic = 1:n
        cors = squeeze(corrst(ir,ic,:));
        pvs = squeeze(pvrst(ir,ic,:));
        if any(cors<0)
            idx = find(cors==min(cors));
            cormin(ir,ic) = cors(idx);
            lgmn(ir,ic) = idx-1;
            if pvs(idx)<=sigp
                corminsg(ir,ic) = cors(idx);
            end
        end
    end
    disp(num2str(ir))
end

corrst(isnan(corrst)) = bv;  % R
pvrst(isnan(pvrst)) = bv;  % P
corsigrst(isnan(corsigrst)) = bv;  % R-sig
for mlg = mlg1:mlg2
    geotiffwrite([outpt,'/NEE_PRP_lag',num2str(mlg,'%02d'),...
        'm_Cor.tif'],single(corrst(:,:,mlg+1)),Rmat)
    geotiffwrite([outpt,'/NEE_PRP_lag',num2str(mlg,'%02d'),...
        'm_CorSig.tif'],single(corsigrst(:,:,mlg+1)),Rmat)
    geotiffwrite([outpt,'/NEE_PRP_lag',num2str(mlg,'%02d'),...
        'm_P.tif'],single(pvrst(:,:,mlg+1)),Rmat)
    
    disp(['Write Cor:',num2str(mlg)])
end

cormin(isnan(cormin)) = bv;  % R-min
corminsg(isnan(corminsg)) = bv;  % Rmin-sig
lgmn(isnan(lgmn)) = bv;  % lag-month

geotiffwrite([outpt,'/NEE_PRP_lagm_MaxNgCor.tif'],single(cormin),Rmat)
geotiffwrite([outpt,'/NEE_PRP_lagm_MaxNgCorSig.tif'],single(corminsg),Rmat)
geotiffwrite([outpt,'/NEE_PRP_lagm_MaxNgCorMonth.tif'],int16(lgmn),Rmat)

delete(parobj);
mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])

