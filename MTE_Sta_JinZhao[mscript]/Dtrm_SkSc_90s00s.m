% Determine the sink or sorce between 1982-1989, 1990-1999, and 2000-2011.
% 2017.4.7
clear;close all;clc

%%  input

NEEmn_pt = '/home/test2/MTE_NEE/NEE_year/ymean';

outpt = '/home/test2/MTE_NEE/NEE_year/Crb_ScSk';

%%  operate

[nrw,ncl] = deal(1752,4320);
Rmat = makerefmat('RasterSize',[nrw ncl],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

NEEmn80s = double(imread([NEEmn_pt,'/NEEgraFlux_82to89_mean.tif']));
NEEmn80s(NEEmn80s==NEEmn80s(1,1)) = nan;

NEEmn90s = double(imread([NEEmn_pt,'/NEEgraFlux_90to99_mean.tif']));
NEEmn90s(NEEmn90s==NEEmn90s(1,1)) = nan;

NEEmn00s = double(imread([NEEmn_pt,'/NEEgraFlux_00to11_mean.tif']));
NEEmn00s(NEEmn00s==NEEmn00s(1,1)) = nan;

NEEmn8090s = double(imread([NEEmn_pt,'/NEEgraFlux_82to99_mean.tif']));
NEEmn8090s(NEEmn8090s==NEEmn8090s(1,1)) = nan;

crb90to80 = nan(nrw,ncl);
crb00to90 = nan(nrw,ncl);
crb00s = nan(nrw,ncl);
for ir = 1:nrw
    for ic = 1:ncl
        tmp80 = NEEmn80s(ir,ic);
        tmp90 = NEEmn90s(ir,ic);
        tmp8090 = NEEmn8090s(ir,ic);
        tmp00 = NEEmn00s(ir,ic);
        if all(~isnan([tmp80,tmp90,tmp8090,tmp00]))
            switch sign(tmp90)-sign(tmp80)
                case -2
                    crb90to80(ir,ic) = -2;
                case 2
                    crb90to80(ir,ic) = 2;
            end
            
            switch sign(tmp00)-sign(tmp90)
                case -2
                    crb00to90(ir,ic) = -2;
                case 2
                    crb00to90(ir,ic) = 2;
            end
            
            switch sign(tmp00)-sign(tmp8090)
                case -2
                    crb00s(ir,ic) = -2;
                case 2
                    crb00s(ir,ic) = 2;
            end
        end
    end
    disp(num2str(ir))
end
crb90to80(isnan(crb90to80)) = -99;
crb00to90(isnan(crb00to90)) = -99;
crb00s(isnan(crb00s)) = -99;

geotiffwrite([outpt,'/CrbScSk90to80.tif'],crb90to80,Rmat)
geotiffwrite([outpt,'/CrbScSk00to90.tif'],crb00to90,Rmat)
geotiffwrite([outpt,'/CrbScSk00to8090.tif'],crb00s,Rmat)

disp('Finish!')
