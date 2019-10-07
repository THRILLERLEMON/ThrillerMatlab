% The correlation coefficient between NEE and PRP, TEM, SWR and GMIF.
% geotiff
% 2017.5.11
tic;clear;close all;clc

%%  Input

Metpt = '/home/test2/MTE_NEE/MeteoData/DETREND';
outpt = '/home/JiQiulei/MTE_JQL_2019/NEE_Sta';  % Outpath

%%  pm

NEE_pt = '/home/JiQiulei/MTE_JQL_2019/NEE_Upscale_Sum2Year/Flux';  % NEE flux yearly data path
NEE_vd = [-5000,10000];

TEM_pt = [Metpt,'/Temperature'];  % TEM yearly data path
TEM_vd = [-100,100];

PRP_pt = [Metpt,'/Precipitation'];  % PRP yearly data path
PRP_vd = [0,20000];

SWR_pt = [Metpt,'/SWrad'];  % SWR yearly data path
SWR_vd = [0,20000];

sigp = 0.05;

%%  Operate

NEE_afs = dir([NEE_pt,'/*.tif']);
PRP_afs = dir([PRP_pt,'/*.tif']);
SWR_afs = dir([SWR_pt,'/*.tif']);
TEM_afs = dir([TEM_pt,'/*.tif']);

[m,n] = deal(1752,4320);
Rmat = makerefmat('RasterSize',[m n],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

NEE_dt = nan(m,n,length(NEE_afs));
PRP_dt = nan(m,n,length(PRP_afs));
SWR_dt = nan(m,n,length(SWR_afs));
TEM_dt = nan(m,n,length(TEM_afs));

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
    
    disp(num2str(fl))
end

rst_cor = nan(m,n,3);  % PRP SWR TEM
rst_corp = nan(m,n,3);
rst_corsig = nan(m,n,3);
rmin = nan(m,n,3);  % Rmin, Rsig min, Rmin sig

parobj=parpool('local',12);
disp('Calculating...')
parfor ir = 1:m
    for ic = 1:n
        NEE = squeeze(NEE_dt(ir,ic,:));
        vars = [squeeze(PRP_dt(ir,ic,:)),...
            squeeze(SWR_dt(ir,ic,:)),...
            squeeze(TEM_dt(ir,ic,:))];  % PRP SWR TEM
        
        rmin1 = nan(3,1);
        pvls = nan(3,1);
        cors = nan(3,1);
        for vr = 1:3
            NEE1 = NEE;
            var1 = vars(:,vr);
            if sum(~isnan(NEE1+var1)) >= 15  %
                idx = isnan(NEE1+var1);
                NEE1(idx) = [];
                var1(idx) = [];
                
                [coef1,pv1] = corrcoef(NEE1,var1);
                pvls(vr) = pv1(1,2);
                cors(vr) = coef1(1,2);
                
                [rst_cor(ir,ic,vr),rst_corp(ir,ic,vr)] = deal(coef1(1,2),pv1(1,2));
                if pv1(1,2) <= sigp
                    rst_corsig(ir,ic,vr) = coef1(1,2);
                end
            end
        end
        if all(~isnan([pvls;cors]))
            idx = find(cors==min(cors));
            rmin1(1) = idx*sign(cors(idx));  % R min
            
            if pvls(idx)<=sigp
                rmin1(3) = idx*sign(cors(idx));  % Rmin sig
            end
            cors(pvls>sigp) = nan;
            if any(~isnan(cors))
                idx1 = find(cors==min(cors));
                rmin1(2) = idx1*sign(cors(idx1));  % Rsig min
            end
            rmin(ir,ic,:) = rmin1;
        end
    end
    disp(num2str(ir))
end
delete(parobj);

rst_cor(isnan(rst_cor)) = -9999;
rst_corp(isnan(rst_corp)) = -9999;
rst_corsig(isnan(rst_corsig)) = -9999;
rmin(isnan(rmin)) = -99;

vnm = {'PRP','SWR','TEM'};
for vr = 1:3
    geotiffwrite([outpt,'/NEEgra_',vnm{vr},'_Cor.tif'],...
        single(rst_cor(:,:,vr)),Rmat)
    geotiffwrite([outpt,'/NEEgra_',vnm{vr},'_CorP.tif'],...
        single(rst_corp(:,:,vr)),Rmat)
    geotiffwrite([outpt,'/NEEgra_',vnm{vr},'_Corsig.tif'],...
        single(rst_corsig(:,:,vr)),Rmat)
    
    disp(vnm{vr})
end

rstr = {'min','sig_min','min_sig'};
for irs = 1:3
    geotiffwrite([outpt,'/NEEgraCor_',rstr{irs},'.tif'],...
        int8(rmin(:,:,irs)),Rmat)
end

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])
