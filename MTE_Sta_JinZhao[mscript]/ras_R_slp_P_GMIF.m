% R2 Slope F P sig-slope
tic
clear;clc;close all;

%%  user

raspt = '/home/LiShuai/Data/Grass_Management/Intensive_frac';
valid = [0,100];
sf = 1;  %scale factor

psig = 0.05;

outpt = '/home/test2/MTE_NEE/MeteoData/slp';
outhds = 'GMIF_82to11';
bv = -9999;

%%  calculate

afs = dir([raspt,'/*.tif']);
fnms = {afs(:).name};

Ginfo = geotiffinfo([raspt,'/',fnms{1}]);
Rmat = Ginfo.RefMatrix;
Gtag = Ginfo.GeoTIFFTags.GeoKeyDirectoryTag;

data = nan(Ginfo.Height, Ginfo.Width, length(fnms));

disp('Reading...')
for i = 1:length(fnms)
    dtmp = imread([raspt,'/',fnms{i}]);
    dtmp = double(dtmp);
    dtmp(dtmp<valid(1) | dtmp>valid(2)) = nan;  % valid
    data(:,:,i) = dtmp*sf;
end

[s1,s2,s3] = size(data);
ras_sts = nan(s1,s2,5); %slpe r2 f p slope_sig
for ir = 1:s1
    for ic = 1:s2
        tmp = squeeze(data(ir,ic,:));
        tmp(isnan(tmp)) = [];
        if sum(tmp==0) < 10
            [b,~,~,~,stats] = regress(tmp,[ones(length(tmp),1),(1:length(tmp))']);
            %if b(2) ~= 0
            ras_sts(ir,ic,1) = b(2);  % slope
            if stats(3) < psig
                ras_sts(ir,ic,5) = b(2);  % slope sig
            end
            %end
            ras_sts(ir,ic,2) = stats(1);  % R2
            ras_sts(ir,ic,3) = stats(2);  % F
            ras_sts(ir,ic,4) = stats(3);  % P
        end
    end
    
    disp(num2str(ir))
end
ras_sts(isnan(ras_sts)) = bv;

%%  write

var = {'slope','r2','F','P','slp_sig'};
for m = 1:5
    geotiffwrite([outpt,'/',outhds,'_',var{m},'.tif']...
        ,ras_sts(:,:,m),Rmat,'GeoKeyDirectoryTag',Gtag)
    disp(var{m})
end
mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])

