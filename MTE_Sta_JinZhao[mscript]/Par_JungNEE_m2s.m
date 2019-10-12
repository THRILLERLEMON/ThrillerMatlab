% Covert monthly NEE of Jung's to yearly and seasonal ones.
% geotiff
% 2017.5.3
tic;clear;close all;clc

%%  input

NEEmpt = '/home/test2/MTE_NEE/JungNEE/monthly';

hds = 'CRUNCEPv6.';
[vd1,vd2] = deal(-5000,5000);
sf = 1;

[yr1,yr2] = deal(1982,2011);

bv = -9999;
outpt = '/home/test2/MTE_NEE/JungNEE/Total/Season';

%%  operate

[nrw,ncl] = deal(360,720);
S1 = referenceSphere('earth','km');
wdzone = ones(nrw,ncl);
Rmat = makerefmat('RasterSize',[nrw ncl],...
    'Latlim',[-90 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');
[~,colarea] = areamat(wdzone,Rmat,S1);
wdarea = repmat(colarea,1,ncl);

strs = {'ANN.NEE_HB','ANN.NEE','MARS.NEE_HB',...
    'MARS.NEE','RF.NEE_HB','RF.NEE'};
for idt = 1:length(strs)
    mkdir(outpt,strs{idt})
end

parobj=parpool('local',13);
parfor idt = 1:length(strs)
    ihd = [hds,strs{idt}];
    outdt = [outpt,'/',strs{idt}];
    
    docnm = {'MAM', 'JJA', 'SON', 'DJF'};
    outflx = [outdt,'/SN_flux'];
    outttl = [outdt,'/SN_total'];
    mkdir(outflx)
    mkdir(outttl)
    for seas = 1:4
        mkdir(outflx,docnm{seas});
        mkdir(outttl,docnm{seas});
    end
    
    for yr = yr1:yr2
        mftmp = nan(nrw,ncl,12);
        for mon = 1:12
            if mon >= 3
                mftmp(:,:,mon-2) = double(imread([NEEmpt,'/',ihd,...
                    '.monthly.',num2str(yr),num2str(mon,'%02d'),'.tif']));
                mftmp(end-11:end,:) = nan;  %%
            else
                if yr ~= yr2
                    mftmp(:,:,mon+10) = double(imread([NEEmpt,'/',...
                        ihd,'.monthly.',num2str(yr+1),...
                        num2str(mon,'%02d'),'.tif']));
                    mftmp(end-11:end,:) = nan;  %%
                end
            end
        end
        
        mftmp(mftmp<vd1 | mftmp>vd2) = nan;
        mftmp = mftmp*sf;
        mttmp = mftmp.*repmat(wdarea,1,1,size(mftmp,3))/10^9;  % PgC/season
        
        for seas = 1:3+(yr~=yr2)
            ftmp = mftmp(:,:,1+3*(seas-1):3+3*(seas-1));
            ttmp = mttmp(:,:,1+3*(seas-1):3+3*(seas-1));
            
            fssn = nansum(ftmp,3);
            tssn = nansum(ttmp,3);
            
            idxssn = sum(~isnan(ftmp),3);
            
            fssn(idxssn==0) = bv;
            tssn(idxssn==0) = bv;
            
            geotiffwrite([outflx,'/',docnm{seas},'/',ihd,...
                num2str(yr),'_',docnm{seas},'_flxsum','.tif'],...
                single(fssn),Rmat)
            geotiffwrite([outttl,'/',docnm{seas},'/',ihd,...
                num2str(yr),'_',docnm{seas},'_ttsum','.tif'],...
                single(tssn),Rmat)
            
            disp([strs{idt},'_',num2str(yr),docnm{seas}])
        end
    end
end
delete(parobj);

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])

