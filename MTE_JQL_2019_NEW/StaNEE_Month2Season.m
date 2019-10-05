% Monthly flux NEE to seasonal flux and total NEE
% spring:3 4 5 summer:6 7 8 autumn:9 10 11 winter 12 1 2
% geotiff
clear;clc;tic

%%  user

NEEmpt = '/home/JiQiulei/MTE_JQL_2019/NEE_Upscale';
head = '';
foot = '_global_grass_NEE_MTEmean.tif';

yrs = [1982,2011];
efrg = [-5000,10000];
sf = 1;

sts = 2;  % 1.mean  2.sum

grabl_fl = '/home/JiQiulei/MTE_JQL_2019/glc2000_10km_grass_bili.tif';


outbv = -9999;
outhdf = 'NEEgra_FluxSum';  % out heads
outhdt = 'NEEgra_TotalSum';
outpt = '/home/JiQiulei/MTE_JQL_2019/NEE_Upscale_Sum2Season';

%%  calculate

[nrw,ncl] = deal(1752,4320);
S1 = referenceSphere('earth','km');
wdzone = ones(nrw,ncl);
Rmat = makerefmat('RasterSize',[nrw ncl],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');
[~,colarea] = areamat(wdzone,Rmat,S1);
wdarea = repmat(colarea,1,ncl);

grabl = double(imread(grabl_fl));
grabl(grabl==grabl(1,1)) = nan;

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
outflx = [outpt,'/SN_flux'];
outttl = [outpt,'/SN_total'];
mkdir(outflx)
mkdir(outttl)
for seas = 1:4
    mkdir(outflx,docnm{seas});
    mkdir(outttl,docnm{seas});
end

disp('Calculate:')
for yr = yrs(1):yrs(2)
    disp(num2str(yr))
    mftmp = nan(nrw,ncl,12);
    for mon = 1:12
        if mon >= 3
            mftmp(:,:,mon-2) = double(imread([NEEmpt,'/',head,...
                num2str(yr),num2str(mon,'%02d'),foot]));
        else
            if yr ~= yrs(2)
                mftmp(:,:,mon+10) = double(imread([NEEmpt,'/',head,...
                    num2str(yr+1),num2str(mon,'%02d'),foot]));
            end
        end
    end
    
    mftmp(mftmp<efrg(1) | mftmp>efrg(2)) = nan;
    mftmp = mftmp*sf;
    mttmp = mftmp.*repmat(wdarea,1,1,size(mftmp,3))...
        .*repmat(grabl,1,1,size(mftmp,3))/10^9;  % PgC/season
    
    for seas = 1:3+(yr~=yrs(2))
        ftmp = mftmp(:,:,1+3*(seas-1):3+3*(seas-1));
        ttmp = mttmp(:,:,1+3*(seas-1):3+3*(seas-1));
        
        fssn = stsfun(ftmp);
        tssn = stsfun(ttmp);
        
        idxssn = sum(~isnan(ftmp),3);
        
        fssn(idxssn==0) = outbv;
        tssn(idxssn==0) = outbv;
        
        geotiffwrite([outflx,'/',docnm{seas},'/',...
            outhdf,num2str(yr),docnm{seas},'_',stsrt,'.tif'],fssn,Rmat)
        geotiffwrite([outttl,'/',docnm{seas},'/',...
            outhdt,num2str(yr),docnm{seas},'_',stsrt,'.tif'],tssn,Rmat)
        
        disp(docnm{seas})
    end
end

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])
