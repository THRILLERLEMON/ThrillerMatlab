% Monthly Met to seasonal Met
% spring:3 4 5 summer:6 7 8 autumn:9 10 11 winter 12 1 2
% geotiff
% 2017.5.2
clear;close all;clc;tic

%%  user

Metmpt = '/home/LiShuai/Data/Long_Radiation_month/day_sum';
hd = '';
ft = '_Long_Wave_Radiation.tif';

yrs = [1982,2011];
efrg = [-5000,100000];
sf = 1;
[m,n] = deal(360,720);

sts = 1;  % 1.mean  2.sum

outhd = 'LongRad';  % out heads
outpt = '/home/test2/MTE_NEE/MeteoData/LongRad/Season';
outbv = -9999;

%%  calculate

[nrw,ncl] = deal(1752,4320);
Rmat = makerefmat('RasterSize',[nrw ncl],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

switch sts
    case 1
        stsfun = @(x)nanmean(x,3);
        stsrt = 'mean';
    case 2
        stsfun = @(x)nansum(x,3);
        stsrt = 'sum';
end

disp('Make dir')
docnm = {'MAM', 'JJA', 'SON', 'DJF'};
for seas = 1:4
    mkdir(outpt,docnm{seas});
end

disp('Calculate:')
for yr = yrs(1):yrs(2)
    disp(num2str(yr))
    mtmp = nan(m,n,12);
    for mon = 1:12
        if mon >= 3
            mtmp(:,:,mon-2) = double(imread([Metmpt,'/',hd,...
                num2str(yr),num2str(mon,'%02d'),ft]));
        else
            if yr ~= yrs(2)
                mtmp(:,:,mon+10) = double(imread([Metmpt,'/',hd,...
                    num2str(yr+1),num2str(mon,'%02d'),ft]));
            end
        end
    end
    
    mtmp(mtmp<efrg(1) | mtmp>efrg(2)) = nan;
    mtmp = mtmp*sf;
    
    for seas = 1:3+(yr~=yrs(2))
        ftmp = mtmp(:,:,1+3*(seas-1):3+3*(seas-1));
        fssn = stsfun(ftmp);
        
        idxssn = sum(~isnan(ftmp),3);
        fssn(idxssn==0) = outbv;
        
        if m<=360
           fssn = kron(fssn,ones(6,6));
        end
        
        fssn = fssn(1:nrw,:);
        
        geotiffwrite([outpt,'/',docnm{seas},'/',outhd,...
            num2str(yr),docnm{seas},'_',stsrt,'.tif'],single(fssn),Rmat)
        
        disp(docnm{seas})
    end
end

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])

