% The correlation coefficient between NEE and PRP, TEM, SWR and GMIF.
% geotiff
% 2017.4.3
tic;clear;close all;clc

%%  Input

Metpt = '/home/test2/MTE_NEE/MeteoData';
outpt = '/home/test2/MTE_NEE/NEE_year/CorSens';  % Outpath

%%  pm

NEE_pt = '/home/test2/MTE_NEE/NEE_year/yflux';  % NEE flux yearly data path
NEE_vd = [-5000,10000];

TEM_pt = [Metpt,'/Temperature'];  % TEM yearly data path
TEM_vd = [-100,100];

PRP_pt = [Metpt,'/Precipitation'];  % PRP yearly data path
PRP_vd = [0,20000];

SWR_pt = [Metpt,'/SWrad'];  % SWR yearly data path
SWR_vd = [0,20000];

GMIF_pt = '/home/LiShuai/Data/Grass_Management/Intensive_frac';
GMIF_vd = [0,100];

sigp = 0.05;

%%  Operate

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
    tmp5 = tmp5(1:292,:)*100;  %%%%
    tmp5 = kron(tmp5,ones(6,6));
    GMIF_dt(:,:,fl) = tmp5;
    
    disp(num2str(fl))
end

rst_cor = nan(m,n,4);  % PRP SWR TEM GMIF
rst_corp = nan(m,n,4);
rst_corsig = nan(m,n,4);

rst_sens = nan(m,n,4);
rst_sensp = nan(m,n,4);
rst_senssig = nan(m,n,4);

parobj=parpool('local',16);
disp('Calculating...')
parfor ir = 1:m
    for ic = 1:n
        NEE = squeeze(NEE_dt(ir,ic,:));
        vars = [squeeze(PRP_dt(ir,ic,:)),...
            squeeze(SWR_dt(ir,ic,:)),...
            squeeze(TEM_dt(ir,ic,:)),...
            squeeze(GMIF_dt(ir,ic,:))];  % PRP SWR TEM GMIF
        
        for vr = 1:4
            NEE1 = NEE;
            var1 = vars(:,vr);
            if vr==4
                var1(var1==0) = nan;
            end
            if sum(~isnan(NEE1+var1)) >= 15  %
                idx = isnan(NEE1+var1);
                NEE1(idx) = [];
                var1(idx) = [];
                
                [coef1,pv1] = corrcoef(NEE1,var1);
                [rst_cor(ir,ic,vr),rst_corp(ir,ic,vr)] = deal(coef1(1,2),pv1(1,2));
                if pv1(1,2) <= sigp
                    rst_corsig(ir,ic,vr) = coef1(1,2);
                end
                
                [b,~,~,~,stats] = regress(NEE1,[var1,ones(length(var1),1)]);
                rst_sens(ir,ic,vr) = b(1);
                rst_sensp(ir,ic,vr) = stats(3);
                if stats(3) <= sigp
                    rst_senssig(ir,ic,vr) = b(1);
                end
            end
        end
    end
    disp(num2str(ir))
end
delete(parobj);

rst_cor(isnan(rst_cor)) = -9999;
rst_corp(isnan(rst_corp)) = -9999;
rst_corsig(isnan(rst_corsig)) = -9999;

rst_sens(isnan(rst_sens)) = -9999;
rst_sensp(isnan(rst_sensp)) = -9999;
rst_senssig(isnan(rst_senssig)) = -9999;

vnm = {'PRP','SWR','TEM','GMIF'};
for vr = 1:4
    geotiffwrite([outpt,'/NEEgra_',vnm{vr},'_Cor.tif'],...
        rst_cor(:,:,vr),Rmat)
    geotiffwrite([outpt,'/NEEgra_',vnm{vr},'_CorP.tif'],...
        rst_corp(:,:,vr),Rmat)
    geotiffwrite([outpt,'/NEEgra_',vnm{vr},'_Corsig.tif'],...
        rst_corsig(:,:,vr),Rmat)
    
    geotiffwrite([outpt,'/NEEgra_',vnm{vr},'_Sens.tif'],...
        rst_sens(:,:,vr),Rmat)
    geotiffwrite([outpt,'/NEEgra_',vnm{vr},'_SensP.tif'],...
        rst_sensp(:,:,vr),Rmat)
    geotiffwrite([outpt,'/NEEgra_',vnm{vr},'_Senssig.tif'],...
        rst_senssig(:,:,vr),Rmat)
    disp(vnm{vr})
end

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])

