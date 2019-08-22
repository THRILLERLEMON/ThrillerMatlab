% 将严老师提供3期land cover合并为文章统计中使用的7类
% 2016.11.30
clear;close all;clc

%%

lcpt = 'D:\VI\LP_landcover\IGBP\rsmp';
outpt = 'D:\VI\LP_landcover\IGBP\reclassify\8类有水体';

%%

afs = dir([lcpt,'\*tif']);

Ginfo = geotiffinfo([lcpt,'\',afs(1).name]);
Rmat = Ginfo.RefMatrix;
Rtag = Ginfo.GeoTIFFTags.GeoKeyDirectoryTag;

for fl = 1:length(afs)
    lcorg = double(imread([lcpt,'\',afs(fl).name]));
    lcrcl = lcorg;
    
    lcrcl(lcorg==2 | lcorg==4) = 1;  % Broadleaf forest
    lcrcl(lcorg==1 | lcorg==3) = 2;  % Needleleaf forest
    lcrcl(lcorg==5) = 3;  % Mix forest
    lcrcl(lcorg==6 | lcorg==7) = 4;  % shrubland
    lcrcl(lcorg>=8 & lcorg<=10) = 5;  % grassland
    lcrcl(lcorg==12 | lcorg==14) = 6;  % cropland
    % lcrcl(lcorg==0 | lcorg==11 | lcorg==13 | lcorg==15 | lcorg==16) = 7;  % Others
    lcrcl(lcorg==0) = 7;  % Water
    lcrcl(lcorg==11 | lcorg==13 | lcorg==15 | lcorg==16) = 8;  % Others
    
    geotiffwrite([outpt,'\',afs(fl).name(1:end-4),'_rcls8.tif'],lcrcl,...
        Rmat,'GeoKeyDirectoryTag',Rtag);
    disp(afs(fl).name)
end

disp('Finish!')
