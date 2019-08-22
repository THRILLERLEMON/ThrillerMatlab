% Extract 8-day BSA and WSA of LP from HDF file.
% HDF, 0.05D, 8-day
close all;clear;clc;tic

%%  input

ABD_pt = 'E:\GLASS_Albedo_AVHRR_1982to2015\HDF';
hd = 'GLASS02B05.V0*.A';
vd = [0,10000];
sf = 1;
vrnms = {'ABD_BSA_shortwave','ABD_WSA_shortwave'};

[yr1,yr2] = deal(1982,2015);
% lonlms = [100.819,114.577];
% latlms = [33.633,41.373];
lonlms = [95.86,119.07];
latlms = [32.215,41.9];

outvrnms = {'BSA','WSA'};
bv = -99;
outpt = 'E:\GLASS_Albedo_AVHRR_1982to2015\YRsqr_8d';

%%  operate

if ~exist(outpt,'dir')
    mkdir(outpt)
end

af1 = dir([ABD_pt,filesep,'*',num2str(yr1),'*.hdf']);
af1 = [ABD_pt,filesep,af1(1).name];
ABDinfo = hdfinfo(af1,'EOS');
nlon = ABDinfo.Grid.Columns;
nlat = ABDinfo.Grid.Rows;

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

for yr = yr1:yr2
    % for idy = 265:8:365
    for idy = 1:8:365
        fl = dir([ABD_pt,filesep,hd,num2str(yr),num2str(idy,'%03d'),'*.hdf']);
        for ivr = 1:2
            tmp = double(hdfread([ABD_pt,filesep,fl.name],...
                vrnms{ivr},'Index',{[row1,col1],[1 1],[rows,cols]}));
            tmp(tmp<vd(1)|tmp>vd(2)) = bv;
            tmp = tmp*sf;
            geotiffwrite([outpt,filesep,'GLASS_',outvrnms{ivr},'_',...
                num2str(yr),num2str(idy,'%03d'),'.tif'],int32(tmp),Rmat)
            clc
            disp([num2str(yr),' ',num2str(idy),' ',outvrnms{ivr}])
        end
    end
end
mins = toc;
disp(['Time:',num2str(mins/60),'mins'])
