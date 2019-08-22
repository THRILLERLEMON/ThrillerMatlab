% GLASS 0.05D 8day HDF to geotiff
% HDF-EOS
% filename: GLASS01B02.V03.A1982001.2012283.hdf
% 2016.9.21
clear;close all;clc

%%  Input

GLlai_pt = 'E:\GLASS_LAI_AVHRR_1982to2015\NetCDF';
hdlen = 16;
vrnm = 'LAI';
vd = [0,1000];
sf = 1;

[yr1,yr2] = deal(1982,2015);

% lonlms = [100.819,114.577];
% latlms = [33.633,41.373];
lonlms = [95.86,119.07];
latlms = [32.215,41.9];

bv = -99;
outhd = 'GLASS_lai_YR';
outpt = 'E:\GLASS_LAI_AVHRR_1982to2015\GeoTiff\YR_8dy_spr_org';

%%  Operate

if ~exist(outpt,'dir')
    mkdir(outpt)
end

af1 = dir([GLlai_pt,filesep,num2str(yr1),filesep,'*.hdf']);
af1 = [GLlai_pt,filesep,num2str(yr1),filesep,af1(1).name];
GLAIinfo = hdfinfo(af1,'EOS');
nlon = GLAIinfo.Grid.Columns;
nlat = GLAIinfo.Grid.Rows;

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

% pobj = parpool('local',2);
for yr = yr1:yr2
    vd1 = vd;
    afs = dir([GLlai_pt,filesep,num2str(yr),filesep,'*.hdf']);
    for fl = 1:length(afs)
        tmp = double(hdfread([GLlai_pt,filesep,num2str(yr),filesep,afs(fl).name],...
            vrnm,'Index',{[row1,col1],[1 1],[rows,cols]}));  % row: 951~1162, col:5597~5930
        tmp(tmp<vd1(1)|tmp>vd1(2)) = nan;
        tmp = tmp*sf;
        tmp(isnan(tmp)) = bv;
        geotiffwrite([outpt,filesep,outhd,...
            afs(fl).name(hdlen+1:hdlen+7),'.tif'],single(tmp),Rmat)
        clc
        disp([num2str(yr),' ',afs(fl).name(hdlen+5:hdlen+7)])
    end
end
% delete(pobj)

disp('Finish!')
