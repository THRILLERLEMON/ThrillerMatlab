% Season NEE R2 Slope F P sig-slope
% geotiff
tic
clear;clc;close all;

%%  user

sn_pt = '/home/test2/MTE_NEE/NEE_year/Season/SN_flux';
outhds = 'NEEgra_FluxSum';

%%  Parameter

efrg1 = -5000;
efrg2 = 10000;
sf = 1;  % scale factor

pvl = 0.05;
bv = -9999;
sstr = {'MAM','JJA','SON','DJF'};

%% Parallel

outpt = [sn_pt,'/slp'];
mkdir(outpt)

[rws,cls] = deal(1752,4320);
Rmat = makerefmat('RasterSize',[rws cls],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

parobj=parpool('local',15);
parfor sn = 1:4
    raspt = [sn_pt,'/',sstr{sn}];
    afs = dir([raspt,'/*.tif']);
    NEEs = nan(rws,cls,length(afs));
    
    for fl = 1:length(afs)
        dtmp = double(imread([raspt,'/',afs(fl).name]));
        dtmp(dtmp<efrg1 | dtmp>efrg2) = nan;  % valid
        NEEs(:,:,fl) = dtmp*sf;
    end
    
    ras_sts = nan(rws,cls,5); %slpe r2 f p slope_sig
    for ir = 1:rws
        for ic = 1:cls
            tmp = squeeze(NEEs(ir,ic,:));
            tmp(isnan(tmp)) = [];
            if length(tmp)>=length(afs)*0.9 || length(unique(tmp))>1
                [b,~,~,~,stats] = regress(tmp,...
                    [(1:length(tmp))',ones(length(tmp),1)]);
                ras_sts(ir,ic,1) = b(1);  % slope
                if stats(3) < pvl
                    ras_sts(ir,ic,5) = b(1);  % slope sig
                end
                ras_sts(ir,ic,2) = stats(1);  % R2
                ras_sts(ir,ic,3) = stats(2);  % F
                ras_sts(ir,ic,4) = stats(3);  % P
            end
        end
    end
    ras_sts(isnan(ras_sts)) = bv;
    
    % write
    var = {'slp','r2','F','P','slp_sig'};
    for m = 1:5
        geotiffwrite([outpt,'/',outhds,'_',sstr{sn},var{m},'.tif'],...
            ras_sts(:,:,m),Rmat)
    end
    disp(sstr{sn})
end
delete(parobj);

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])
