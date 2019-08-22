% The coefficient of partial correlation between ETa with LAI, PRP and PET
% geotiff
% 2016.10.20
tic;clear;close all;clc

%%  Input

tifpt = '/home/test2/VImod/VI_simu/VI_SR01/LP_out_tif';

%%  pm
ETa_pt = [tifpt,'/ETa'];  % ETa yearly data path
ETa_vd = [0,2000];
ETa_sf = 1;

PRP_pt = [tifpt,'/PRP'];  % PRP yearly data path
PRP_vd = [0,3000];
PRP_sf = 1;

PET_pt = [tifpt,'/ETp'];  % PET yearly data path
PET_vd = [0,2000];
PET_sf = 1;

LAI_pt = '/home/test2/VImod/GLASS_LAI_HDF/GeoTiff/LP_year_grow/2000s';  % LAI yearly data path
LAI_vd = [0,10];
LAI_sf = 1;

sigp = 0.05;

outpt = [tifpt,'/Parcor'];  % Outpath

%%  Operate

mkdir(outpt)

ETa_afs = dir([ETa_pt,'/*.tif']);
PRP_afs = dir([PRP_pt,'/*.tif']);
PET_afs = dir([PET_pt,'/*.tif']);
LAI_afs = dir([LAI_pt,'/*.tif']);

Ginfo = geotiffinfo([ETa_pt,'/',ETa_afs(1).name]);
Rmat = Ginfo.RefMatrix;
Rtag = Ginfo.GeoTIFFTags.GeoKeyDirectoryTag;
[m,n] = deal(Ginfo.Height, Ginfo.Width);

ETa_dt = nan(m,n,length(ETa_afs));
PRP_dt = nan(m,n,length(ETa_afs));
PET_dt = nan(m,n,length(ETa_afs));
LAI_dt = nan(m,n,length(ETa_afs));

disp('Reading...')
for fl = 1:length(ETa_afs)
    tmp1 = double(imread([ETa_pt,'/',ETa_afs(fl).name]));  % ETa
    tmp1(tmp1<ETa_vd(1) | tmp1>ETa_vd(2)) = nan;
    tmp1 = tmp1*ETa_sf;
    ETa_dt(:,:,fl) = tmp1;
    
    tmp2 = double(imread([PRP_pt,'/',PRP_afs(fl).name]));  % PRP
    tmp2(tmp2<PRP_vd(1) | tmp2>PRP_vd(2)) = nan;
    tmp2 = tmp2*PRP_sf;
    PRP_dt(:,:,fl) = tmp2;
    
    tmp3 = double(imread([PET_pt,'/',PET_afs(fl).name]));  % PET
    tmp3(tmp3<PET_vd(1) | tmp3>PET_vd(2)) = nan;
    tmp3 = tmp3*PET_sf;
    PET_dt(:,:,fl) = tmp3;
    
    tmp4 = double(imread([LAI_pt,'/',LAI_afs(fl).name]));  % LAI
    tmp4(tmp4<LAI_vd(1) | tmp4>LAI_vd(2)) = nan;
    tmp4 = tmp4*LAI_sf;
    LAI_dt(:,:,fl) = tmp4;
end

rst_r = nan(m,n,3);  % PRP PET LAI
rst_p = nan(m,n,3);
rst_rsig = nan(m,n,3);

for ir = 1:m
    for ic = 1:n
        ETa = squeeze(ETa_dt(ir,ic,:));
        PRP = squeeze(PRP_dt(ir,ic,:));
        PET = squeeze(PET_dt(ir,ic,:));
        LAI = squeeze(LAI_dt(ir,ic,:));
        if all(sum(isnan([ETa;PRP;PET;LAI]))==0)
            [rst_r(ir,ic,1),rst_p(ir,ic,1)] = partialcorr(ETa,PRP,[PET,LAI]);  % PRP
            if rst_p(ir,ic,1)<=sigp
                rst_rsig(ir,ic,1) = rst_r(ir,ic,1);
            end
            
            [rst_r(ir,ic,2),rst_p(ir,ic,2)] = partialcorr(ETa,PET,[PRP,LAI]);  % PET
            if rst_p(ir,ic,2)<=sigp
                rst_rsig(ir,ic,2) = rst_r(ir,ic,2);
            end
            [rst_r(ir,ic,3),rst_p(ir,ic,3)] = partialcorr(ETa,LAI,[PET,PRP]);  % NDVI
            if rst_p(ir,ic,3)<=sigp
                rst_rsig(ir,ic,3) = rst_r(ir,ic,3);
            end
        end
    end
    disp(num2str(ir))
end

rst_r(isnan(rst_r)) = -9999;
rst_p(isnan(rst_p)) = -9999;
rst_rsig(isnan(rst_rsig)) = -9999;

vnm = {'PRP','PET','LAI'};
for vr = 1:3
    geotiffwrite([outpt,'/ETa_',vnm{vr},'_R.tif'],rst_r(:,:,vr),...
        Rmat,'GeoKeyDirectoryTag',Rtag)
    geotiffwrite([outpt,'/ETa_',vnm{vr},'_P.tif'],rst_p(:,:,vr),...
        Rmat,'GeoKeyDirectoryTag',Rtag)
    geotiffwrite([outpt,'/ETa_',vnm{vr},'_Rsig.tif'],rst_rsig(:,:,vr),...
        Rmat,'GeoKeyDirectoryTag',Rtag)
    
    disp(vnm{vr})
end

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])
