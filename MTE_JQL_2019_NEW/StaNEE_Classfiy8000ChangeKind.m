% geotiff
% 2017.5.5
clear;close all;clc

%%  input   1-2

Ras00sPt = 'E:\OFFICE\MTE_NEE_DATA\RunResult\Sta_NEE\80s00s\NEEflux_2000-2011_mean.tif';
Ras80sPt = 'E:\OFFICE\MTE_NEE_DATA\RunResult\Sta_NEE\80s00s\NEEflux_1982-1989_mean.tif';
DifRasPt = 'E:\OFFICE\MTE_NEE_DATA\RunResult\Sta_NEE\80s00s\YearsMean00s-80s.tif';


%%  operate

Rmat = makerefmat('RasterSize',[1752 4320],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

Ras00s = double(imread(Ras00sPt));
Ras00s(Ras00s==Ras00s(1,1)) = nan;
sig00s=sign(Ras00s);
sig00s(isnan(Ras00s))= nan;

Ras80s = double(imread(Ras80sPt));
Ras80s(Ras80s==Ras80s(1,1)) = nan;
sig80s=sign(Ras80s);
sig80s(isnan(Ras80s))= nan;

RasDif = double(imread(DifRasPt));
RasDif(RasDif==RasDif(1,1)) = nan;
sigDif=sign(RasDif);
sigDif(isnan(RasDif))= nan;

%    00s     80s     dif     res
%    -       +       +-      1       由碳源变成碳汇
%    +       -       +-      2       由碳汇变成碳源
%    -       -       +       3       碳吸收能力下降
%    -       -       -       4       碳吸收能力上升
%    +       +       +       5       碳释放能力上升
%    +       +       -       6       碳释放能力下降
ResRas=nan(1752,4320);
ResRas(~isnan(RasDif))=0;

ResRas(sig00s==-1 & sig80s==1)=1;
ResRas(sig00s==1 & sig80s==-1)=2;
ResRas(sig00s==-1 & sig80s==-1 & sigDif==1)=3;
ResRas(sig00s==-1 & sig80s==-1 & sigDif==-1)=4;
ResRas(sig00s==1 & sig80s==1 & sigDif==1)=5;
ResRas(sig00s==1 & sig80s==1 & sigDif==-1)=6;

ResRas(isnan(ResRas)) = -128;
geotiffwrite('E:\OFFICE\MTE_NEE_DATA\RunResult\Sta_NEE\80s00s\Classfiy80s00sChangeKind.tif',ResRas,Rmat);

disp('Finish!')