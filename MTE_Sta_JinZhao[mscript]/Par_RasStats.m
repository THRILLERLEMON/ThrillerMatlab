% parallel stats
% geotiff
% 2017.4.3
clear;close all;clc

%%  Input

raspt = '/home/test2/MTE_NEE/MeteoData';
% raspt = '/home/LiShuai/Data/Grass_Management';
outpt = '/home/test2/MTE_NEE/MeteoData/stats';

vrnm = {'Precipitation','SWrad','Temperature'};
% vrnm = {'Intensive_frac'};
efrg = [[0,20000];...
        [0,15000];...
        [-200,200]];
% efrg = [0,1];
sf = [1,1,1];
% sf = 1;

%%  Parallel

parobj = parpool('local',7);

disp('Parallel')
efrg1 = efrg(:,1);
efrg2 = efrg(:,2);

parfor vr = 1:length(vrnm)
    afs = dir([raspt,'/',vrnm{vr},'/*.tif']);
    rst = nan(length(afs),1);
    for fl = 1:length(afs)
        tmp = double(imread([raspt,'/',vrnm{vr},'/',afs(fl).name]));
        tmp(tmp<efrg1(vr) | tmp>efrg2(vr)) = nan;
        tmp = tmp*sf(vr);
        rst(fl) = nanmean(tmp(:));
    end
    dlmwrite([outpt,'/',vrnm{vr},'_mean.txt'],rst)
    disp(vrnm{vr})
end
delete(parobj)

disp('Finish!')

