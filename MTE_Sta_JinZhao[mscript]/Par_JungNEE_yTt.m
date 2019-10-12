% Covert yearly flux NEE of Jung's to total NEE.
% geotiff
% 2017.5.3
tic;clear;close all;clc

%%  input

NEEypt = '/home/test2/MTE_NEE/JungNEE/Flux/yearly';

hds = 'CRUNCEPv6.';
[vd1,vd2] = deal(-5000,5000);
sf = 1;

[yr1,yr2] = deal(1982,2011);

bv = -9999;
outpt = '/home/test2/MTE_NEE/JungNEE/Total/yearly';

%%  operate

[nrw,ncl] = deal(360,720);
S1 = referenceSphere('earth','km');
wdzone = ones(nrw,ncl);
Rmat = makerefmat('RasterSize',[nrw ncl],...
    'Latlim',[-90 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');
[~,colarea] = areamat(wdzone,Rmat,S1);
wdarea = repmat(colarea,1,ncl);

strs = {'ANN','MARS','RF'};
for idt = 1:length(strs)
    mkdir(outpt,strs{idt})
end

parobj=parpool('local',4);
parfor idt = 1:length(strs)
    ihd = [hds,strs{idt}];
    
    for yr = yr1:yr2
        yftmp = double(imread([NEEypt,'/',strs{idt},'/',...
            ihd,'.NEE.annual.',num2str(yr),'.tif']));
        yftmp(end-11:end,:) = nan;  %%
        
        yftmp(yftmp<vd1 | yftmp>vd2) = nan;
        yftmp = yftmp*sf;
        yttmp = yftmp.*wdarea/10^9;  % PgC/season
            
        yttmp(isnan(yttmp)) = bv;
        
        geotiffwrite([outpt,'/',strs{idt},'/',ihd,num2str(yr),...
            '_ttsum','.tif'],single(yttmp),Rmat)
        
        disp([strs{idt},'_',num2str(yr)])
    end
end
delete(parobj);

mins = toc;
disp(['Time:',num2str(mins/60),'minutes'])

