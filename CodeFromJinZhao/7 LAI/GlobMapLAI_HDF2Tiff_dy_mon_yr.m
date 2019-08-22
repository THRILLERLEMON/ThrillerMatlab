% % GLOBMAP 0.0727D 16days(1982-1999)/8day(2000-2017) HDF to geotiff
% HDF-EOS
% filename: GLASS01B02.V03.A1982001.2012283.hdf
% 2019.1.15
clear;close all;clc

%%  input

GLlai_pt = 'D:\GLOBMAP\HDF';
vrnm = 'LAI';
vd = [1e-9,1000];
sf = 0.01;

[yr1,yr2] = deal(1982,1982);
[mn1,mn2] = deal(4,9);

% LP
lonlms = [100.819,114.577];
latlms = [33.633,41.373];
% % CHN
% lonlms = [73,135.08];
% latlms = [18.1608,53.5579];

bv = -99;
outpt = 'D:\GLOBMAP\GLOBMAP_LP';

%%  operate

if ~exist([outpt,filesep,'Day'],'dir')
    mkdir([outpt,filesep,'Day'])
end
if ~exist([outpt,filesep,'Month'],'dir')
    mkdir([outpt,filesep,'Month'])
end
if ~exist([outpt,filesep,'Year'],'dir')
    mkdir([outpt,filesep,'Year'])
end

nlon = 4950;
nlat = 2090;

lattop = 90-152*11/nlat;

col1 = max([1,ceil((lonlms(1)+180)/(360/nlon))]);
col2 = ceil((lonlms(2)+180)/(360/nlon));
cols = col2-col1+1;
row1 = max([1,ceil(-(latlms(2)-lattop)/(152/nlat))]);
row2 = ceil(-(latlms(1)-lattop)/(152/nlat));
rows = row2-row1+1;

Rmat = makerefmat('RasterSize',[rows,cols],...
    'Latlim',[lattop-row2*152/nlat,lattop-(row1-1)*152/nlat],...
    'Lonlim',[-180+(col1-1)*360/nlon,-180+col2*360/nlon],...
    'ColumnsStartFrom','north');

mon_p = [31,28,31,30,31,30,31,31,30,31,30,31];
for yr = yr1:yr2
    fprintf('\n%d',yr)
    mons1 = mon_p;
    if mod(yr,400)==0 || (mod(yr,4)==0 && mod(yr,100)~=0)
        mons1(2)=29;
    end
    mons2 = cumsum(mons1);
    
    afs = dir([GLlai_pt,filesep,'GlobMapLAIV3.A',num2str(yr),'*.Global.hdf']);
    y_tmp = [];
    for mon = 1:12
        fprintf('\n%6d: ',mon)
        m_tmp = [];
        for fl = 1:length(afs)
            if find(mons2 >= str2double(afs(fl).name(19:21)),1,'first') == mon
                tmp = double(hdfread([GLlai_pt,filesep,afs(fl).name],...
                    vrnm,'Index',{[row1,col1],[1 1],[rows,cols]}));
                tmp(tmp<vd(1)|tmp>vd(2)) = nan;
                tmp = tmp*sf;
                m_tmp = cat(3,m_tmp,tmp);
                tmp(isnan(tmp)) = bv;
                geotiffwrite([outpt,filesep,'Day',...
                    filesep,afs(fl).name(1:end-3),'tif'],single(tmp),Rmat)
                fprintf('%-4d',str2double(afs(fl).name(19:21)))
            end
        end
        rst = max(m_tmp,[],3);  % !!!!!
        rst(sum(~isnan(m_tmp),3)==0) = nan;
        if mon>=mn1 && mon<=mn2
            y_tmp = cat(3,y_tmp,rst);
        end
        rst(isnan(rst)) = bv;
        geotiffwrite([outpt,filesep,'Month',filesep,'GlobMapLAIV3.A',...
            num2str(yr),num2str(mon,'%02d'),'_Max.tif'],single(rst),Rmat)
    end
    rsty = nanmean(y_tmp,3);  % !!!!
    rsty(sum(~isnan(y_tmp),3)==0) = bv;
    geotiffwrite([outpt,filesep,'Year',filesep,'GlobMapLAIV3.A',...
        num2str(yr),'_M',num2str(mn1,'%02d'),'to',num2str(mn2,'%02d'),...
        '_Mean.tif'],single(rsty),Rmat)
end

fprintf('\n%s\n','Finish!')
