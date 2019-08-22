% Caculate R2, Slope, F-value, P-value and Significant slope.
% VImod--MATLAB
% Geotiff, LINUX
tic;clear;clc;close all;

%%  doc year

ncrs = 11;

LP_pt = '/home/test2/VImod/VI_simu/VI_AVHLai01/LP_out_old';
prefix = '00to15';
yr1 = 2000;
yr2 = 2015;

psig = 0.05;  % siginificance level

%%  parameter

smp = '/home/test2/VImod/NDVI_Detrend/NDVI_org_82to12/NDVIlp2000097.tif';
% vrnm = {'Et','Bw'};
vrnm = {'ETa','ETp','Ec','Es',...
    'G','H','Rs','Rsn','Rnl','Rn'};
bv = -9999;
Ginfo = geotiffinfo(smp);
Rmat = Ginfo.RefMatrix;
Rtag = Ginfo.GeoTIFFTags.GeoKeyDirectoryTag;
[m,n] = deal(Ginfo.Height, Ginfo.Width);

%%  Parallel

outpt = [LP_pt,filesep,'Ras_Slope'];
mkdir(outpt)
for vr = 1:length(vrnm)
    outpt1 = [outpt,filesep,vrnm{vr}];
    if ~exist(outpt1,'dir')
        mkdir(outpt1)
    end
end

parobj = parpool('local',ncrs);
parfor vr = 1:length(vrnm)
    ras_pt = [LP_pt,filesep,vrnm{vr},filesep,'year'];  %%%%%%
    outvr_pt = [outpt,filesep,vrnm{vr}];
    
    % calculate
    ras_yrs = nan(m,n,yr2-yr1+1);
    for yr = yr1:yr2
        dtmp = double(imread([ras_pt,filesep,vrnm{vr},num2str(yr),'.tif']));
        dtmp(dtmp==bv) = nan;  % back value
        ras_yrs(:,:,yr-yr1+1) = dtmp;
    end
    
    ras_sts = nan(m,n,5);  % slpe r2 f p slope_sig
    for ir = 1:m
        for ic = 1:n
            tmp = squeeze(ras_yrs(ir,ic,:));
            tmp(isnan(tmp)) = [];
            if length(tmp) >= (yr2-yr1+1)*0.9 || length(unique(tmp))>1
                [b,~,~,~,stats] = regress(tmp, [(1:length(tmp))',ones(length(tmp),1)]);
                %if b(2) ~= 0
                ras_sts(ir,ic,1) = b(1);  % slope
                if stats(3) < psig
                    ras_sts(ir,ic,5) = b(1);  % slope sig
                end
                %end
                ras_sts(ir,ic,2) = stats(1);  % R2
                ras_sts(ir,ic,3) = stats(2);  % F
                ras_sts(ir,ic,4) = stats(3);  % P
            end
        end
    end
    ras_sts(isnan(ras_sts)) = bv;
    
    % write
    var = {'slp','r2','F','P','slp_sig'};
    for sts = 1:5
        geotiffwrite([outvr_pt,filesep,vrnm{vr},'_',prefix,'_',var{sts},'.tif'], ...
            ras_sts(:,:,sts), Rmat, 'GeoKeyDirectoryTag', Rtag)
    end
    disp(vrnm{vr})
end
mins = toc;

delete(parobj);
disp(['Time: ',num2str(mins/60),' mins'])
