% Calculate the mean and std NEE at different levels of precipitation.
% geotiff
% 2017.5.10
clear;close all;clc

%%  input

NEE_fl = '/home/test2/MTE_NEE/NEE_new02/ymean/NEEfluxsum_82to11_mean.tif';
PRP_fl = '/home/test2/MTE_NEE/MeteoData/Precipitation/mean/PRP_82to11_mean.tif';

Pstp = 10;

outpt = '/home/test2/MTE_NEE/NEE_new02/Stat/PRP10';

%%  operate

NEE = double(imread(NEE_fl));
NEE(NEE==NEE(1,1)) = nan;

PRP = double(imread(PRP_fl));
PRP(PRP==PRP(1,1)) = nan;
PRP(isnan(NEE)) = nan;

PRP2 = PRP(:);
PRP2(isnan(PRP2)) = [];

% prg = 0:Pstp:prctile(PRP2,99);
prg = 0:Pstp:2000;
prg = [prg,prg(end)+Pstp]';

rst = nan(length(prg)-1,3);  % mean std num
for x = 1:length(prg)-1
    idx = find(PRP>=prg(x) & PRP<prg(x+1));
    if ~isempty(idx)
        NEEtmp = NEE(idx);
        if any(~isnan(NEEtmp))
            rst(x,1) = nanmean(NEEtmp);
            rst(x,2) = nanstd(NEEtmp);
            rst(x,3) = sum(~isnan(NEEtmp));
        end
    end
    disp([num2str(prg(x)),'---',num2str(prg(x+1))])
end

dlmwrite([outpt,'/PRPlv',num2str(Pstp),'_NEE.txt'],...
    [prg(2:end),rst],'delimiter',' ')

disp('Finish!')

