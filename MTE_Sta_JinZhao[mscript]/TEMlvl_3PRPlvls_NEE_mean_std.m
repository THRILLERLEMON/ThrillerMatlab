% Calculate the mean and std NEE at different levels of TEM in different levels of PRP.
% geotiff
% 2017.5.10
clear;close all;clc

%%  input

NEE_fl = '/home/test2/MTE_NEE/NEE_new02/ymean/NEEfluxsum_82to11_mean.tif';
PRP_fl = '/home/test2/MTE_NEE/MeteoData/Mean/PRP_82to11_mean.tif';
TEM_fl = '/home/test2/MTE_NEE/MeteoData/Mean/TEM_82to11_mean.tif';

Tstp = 0.1;

Prg = [90,200,500,2000];

outpt = '/home/test2/MTE_NEE/NEE_new02/Stat/PRP90to2000';

%%  operate

NEE = double(imread(NEE_fl));
NEE(NEE==NEE(1,1)) = nan;

PRP = double(imread(PRP_fl));
PRP(PRP==PRP(1,1)) = nan;
PRP(isnan(NEE)) = nan;

TEM = double(imread(TEM_fl));
TEM(TEM==TEM(1,1)) = nan;
TEM(isnan(NEE)) = nan;

for px = 1:length(Prg)-1
    disp(num2str(Prg(px)))
    
    NEE2 = NEE;
    NEE2(~(PRP>=Prg(px) & PRP<=Prg(px+1))) = nan;
    
    PRP2 = PRP;
    PRP2(~(PRP>=Prg(px) & PRP<=Prg(px+1))) = nan;
    
    TEM2 = TEM;
    TEM2(~(PRP>=Prg(px) & PRP<=Prg(px+1))) = nan;
    
    TEM3 = TEM2(:);
    TEM3(isnan(TEM3)) = [];
    
    Trg = prctile(TEM3,1):Tstp:prctile(TEM3,99);
    Trg = [Trg,Trg(end)+Tstp]';

    rst = nan(length(Trg)-1,3);  % mean std num
    for x = 1:length(Trg)-1
        idx = find(TEM2>=Trg(x) & TEM2<Trg(x+1));
        if ~isempty(idx)
            NEEtmp = NEE2(idx);
            if any(~isnan(NEEtmp))
                rst(x,1) = nanmean(NEEtmp);
                rst(x,2) = nanstd(NEEtmp);
                rst(x,3) = sum(~isnan(NEEtmp));
            end
        end
        disp([num2str(Trg(x)),'---',num2str(Trg(x+1))])
    end
    dlmwrite([outpt,'/TEMlv_PRPlv',num2str(px),'_NEE.txt'],...
        [Trg(2:end),rst],'delimiter',' ') 
end

disp('Finish!')
