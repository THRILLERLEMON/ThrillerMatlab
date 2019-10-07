% Count the number of years when NEE was positive/negative in 1982-2011.
% Caculate the total amount of possitive/negative NEE in 1982-2011.
% 2017.3.28
clear;close all;clc;tic

%%  input

NEEflx_fl = '/home/JiQiulei/MTE_JQL_2019/NEE_Upscale_Sum2Year/Flux';
hdf = 'NEEgra_FluxSum_';
ftf = '_01to12.tif';

NEEtt_fl = '/home/JiQiulei/MTE_JQL_2019/NEE_Upscale_Sum2Year/Total';
hdt = 'NEEgra_FluxSum_';
ftt = '_01to12_total.tif';

yrs = [1982,2011];
outhds = 'NEEgra';
bv = -9999;
outpt = '/home/JiQiulei/MTE_JQL_2019/NEE_Sta';

%%  operate

[nrw,ncl] = deal(1752,4320);
Rmat = makerefmat('RasterSize',[nrw ncl],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

Pnum = zeros(nrw,ncl);
Pfsum = zeros(nrw,ncl);
Ptsum = zeros(nrw,ncl);

Nnum = zeros(nrw,ncl);
Nfsum = zeros(nrw,ncl);
Ntsum = zeros(nrw,ncl);

for yr = yrs(1):yrs(2)
    ftmp = double(imread([NEEflx_fl,'/',hdf,num2str(yr),ftf]));
    ftmp(ftmp==ftmp(1,1)) = nan;
    
    ttmp = double(imread([NEEtt_fl,'/',hdt,num2str(yr),ftt]));
    ttmp(ttmp==ttmp(1,1)) = nan;
    
    Pnum = Pnum+double(ftmp>0);
    Nnum = Nnum+double(ftmp<=0);
    
    Pfsum(ftmp>0) = Pfsum(ftmp>0)+ftmp(ftmp>0);
    Ptsum(ttmp>0) = Pfsum(ttmp>0)+ttmp(ttmp>0);
    
    Nfsum(ftmp<=0) = Nfsum(ftmp<=0)+ftmp(ftmp<=0);
    Ntsum(ttmp<=0) = Ntsum(ttmp<=0)+ttmp(ttmp<=0);
    
    disp(num2str(yr))
end

idxp = Pnum==0;
Pnum(idxp) = bv;
Pfsum(idxp) = bv;
Ptsum(idxp) = bv;

idxn = Nnum==0;
Nnum(idxn) = bv;
Nfsum(idxn) = bv;
Ntsum(idxn) = bv;

geotiffwrite([outpt,'/',outhds,'_',...
    num2str(yrs(1)),'to',num2str(yrs(2)),'_psYnum.tif'],int8(Pnum),Rmat)
geotiffwrite([outpt,'/',outhds,'_',...
    num2str(yrs(1)),'to',num2str(yrs(2)),'_psFlxSum.tif'],single(Pfsum),Rmat)
geotiffwrite([outpt,'/',outhds,'_',...
    num2str(yrs(1)),'to',num2str(yrs(2)),'_psTtSum.tif'],single(Ptsum),Rmat)

geotiffwrite([outpt,'/',outhds,'_',...
    num2str(yrs(1)),'to',num2str(yrs(2)),'_ngYnum.tif'],int8(Nnum),Rmat)
geotiffwrite([outpt,'/',outhds,'_',...
    num2str(yrs(1)),'to',num2str(yrs(2)),'_ngFlxSum.tif'],single(Nfsum),Rmat)
geotiffwrite([outpt,'/',outhds,'_',...
    num2str(yrs(1)),'to',num2str(yrs(2)),'_ngTtSum.tif'],single(Ntsum),Rmat)

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])

