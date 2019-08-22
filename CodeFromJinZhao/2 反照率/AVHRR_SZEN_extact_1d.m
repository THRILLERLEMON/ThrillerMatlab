% Extract daily SZEN of LP from NC file.
% HNetCDF, 0.05D, daily
close all;clear;clc

%%  input

AVH_pt = 'E:\AVHRR_LTDR_2013to2015\NC';
hd = 'AVHRR-Land_v00*_AVH09C1_NOAA-**_';
vd = [-9000,9000];
sf = 100;
vrnm = 'SZEN';

[yr1,yr2] = deal(2013,2015);
% lonlms = [100.819,114.577];
% latlms = [33.633,41.373];
lonlms = [95.86,119.07];
latlms = [32.215,41.9];

bv = -9999;
outpt = 'E:\AVHRR_LTDR_2013to2015\YRsq_1d';

%%  operate

if ~exist(outpt,'dir')
    mkdir(outpt)
end

af1 = dir([AVH_pt,filesep,'*.nc']);
af1 = [AVH_pt,filesep,af1(1).name];
nlon=ncinfo(af1,'longitude'); nlon = nlon.Size;
nlat=ncinfo(af1,'latitude'); nlat = nlat.Size;

col1 = max([1,ceil((lonlms(1)+180)/(360/nlon))]);
col2 = ceil((lonlms(2)+180)/(360/nlon));
cols = col2-col1+1;
row1 = max([1,ceil(-(latlms(2)-90)/(180/nlat))]);
row2 = ceil(-(latlms(1)-90)/(180/nlat));
rows = row2-row1+1;

Rmat = makerefmat('RasterSize',[rows,cols],...
    'Latlim',[90-row2*180/nlat,90-(row1-1)*180/nlat],...
    'Lonlim',[-180+(col1-1)*360/nlon,-180+col2*360/nlon],...
    'ColumnsStartFrom','north');
% Rmat1 = makerefmat('RasterSize',[3600 7200],...
%     'Lonlim',[-180 180],'Latlim',[-90 90],'ColumnsStartFrom','north');

mons = [31,28,31,30,31,30,31,31,30,31,30,31];
for yr = yr1:yr2
    mons1 = mons;
    if mod(yr,400)==0 || (mod(yr,4)==0 && mod(yr,100)~=0)
        mons1(2) = 29;
    end
    mons2 = [0,cumsum(mons1)];
    for imn = 1:12
        for idy = 1:mons1(imn)
            if yr==2014 && imn==5 && idy==3
                fl1 = dir([AVH_pt,filesep,hd,num2str(2014),...
                    num2str(5,'%02d'),num2str(2,'%02d'),'_c*.nc']);
                tmp1 = double(ncread([AVH_pt,filesep,fl1.name],...
                    vrnm,[col1 row1 1],[cols rows 1],[1 1 1]))'*sf;
                fl2 = dir([AVH_pt,filesep,hd,num2str(2014),...
                    num2str(5,'%02d'),num2str(4,'%02d'),'_c*.nc']);
                tmp2 = double(ncread([AVH_pt,filesep,fl2.name],...
                    vrnm,[col1 row1 1],[cols rows 1],[1 1 1]))'*sf;
                tmp = nanmean(cat(3,tmp1,tmp2),3);
            else
                fl = dir([AVH_pt,filesep,hd,num2str(yr),...
                    num2str(imn,'%02d'),num2str(idy,'%02d'),'_c*.nc']);
                tmp = double(ncread([AVH_pt,filesep,fl.name],...
                    vrnm,[col1 row1 1],[cols rows 1],[1 1 1]))'*sf;
            end
            tmp(isnan(tmp)) = bv;
            tmp = round(tmp);
            doy = mons2(imn)+idy;
            geotiffwrite([outpt,filesep,'AVHRR_SZEN_',num2str(yr),...
                num2str(doy,'%03d'),'.tif'],int32(tmp),Rmat)
            clc
            disp([num2str(yr),' ',num2str(doy)])
        end
    end
end
disp('Finish!')
