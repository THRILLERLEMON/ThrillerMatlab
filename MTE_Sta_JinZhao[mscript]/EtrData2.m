
% 2017.4.4
clear;close all;clc

%%  input

NEE_fl = '/home/test2/MTE_NEE/NEE_year/ScatterData/NEE_ave.txt';
PRP_fl = '/home/test2/MTE_NEE/NEE_year/ScatterData/PRP_ave.txt';
SWR_fl = '/home/test2/MTE_NEE/NEE_year/ScatterData/SWR_ave.txt';

outfl = '/home/test2/MTE_NEE/NEE_year/ScatterData/ScatterMat.txt';

%%  operate

NEE = dlmread(NEE_fl);
PRP = dlmread(PRP_fl);
PRP(PRP>5000) = nan;
SWR = dlmread(SWR_fl);

idx = find(isnan(PRP));

NEE(idx) = [];
PRP(idx) = [];
SWR(idx) = [];

PRPx = 0:50:5000;
SWRy = 2000:50:10000;
NEEz = nan(length(PRPx)-1,length(SWRy)-1);
for prg = 1:length(PRPx)-1
    for rrg = 1:length(SWRy)-1
        idx = find((PRP>=PRPx(prg) & PRP<PRPx(prg)+50) & ...
            (SWR>=SWRy(rrg) & SWR<SWRy(rrg)+50));
        NEEz(prg,rrg) = nanmean(NEE(idx));
    end
end
NEEz(isnan(NEEz)) = -99999;
dlmwrite(outfl,NEEz,'delimiter',' ')

disp('Finish!')

