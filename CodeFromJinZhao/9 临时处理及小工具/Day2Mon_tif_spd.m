% Day to Month
% Date:2008056

clear;close all;clc

%%  user

raspt = 'I:\MODIS_NDVI_HDF\mosaic';  % daily data path

hds = 'MOD13A3.A';

vd = [0,10];  % effective range
sf = 1;  % scale factor

ygap = [2013,2013];  % 
stats = 1;  % 1.mean 2.sum

bv = -9999;  
outhd = 'MOD13A3.A';  % 结果前缀
outpt = 'I:\MODIS_NDVI_HDF\Mon_Max';  % 结果输出目录

%%  calculate

mon_p = [31,28,31,30,31,30,31,31,30,31,30,31];
ynum = length(hds)+1;

for yr = ygap(1):ygap(2)
    fprintf([num2str(yr),':'])
    
    mons1 = mon_p;
    if mod(yr,400)==0 || (mod(yr,4)==0 && mod(yr,100)~=0)
        mons1(2)=29;
    end
    mons2 = cumsum(mons1);
    
    afs = dir([raspt,'\',hds,num2str(yr),'*.tif']);
    Ginfo = geotiffinfo([raspt,'\',afs(1).name]);
    [m,n] = deal(Ginfo.Height,Ginfo.Width);
    Rmat = Ginfo.RefMatrix;
    Rtag = Ginfo.GeoTIFFTags.GeoKeyDirectoryTag;
    for mon = 1:12
        m_tmp = zeros(m,n);
        idxn = zeros(m,n);
        for fl = 1:length(afs)
            if find(mons2>=str2double(afs(fl).name(ynum+4:ynum+6)),1,'first')==mon
                tmp = double(imread([raspt,'\',afs(fl).name]));
                tmp(tmp<vd(1)|tmp>vd(2)) = nan;
                tmp = tmp*sf;
                m_tmp = m_tmp+tmp;
                idxn = idxn+~isnan(tmp);
            end
        end
        if sum(m_tmp(:))~=0
            if stats==1
                m_tmp = m_tmp./idxn;
                sfx = 'mean';
            elseif stats==2
                sfx = 'sum';
            end
            
            geotiffwrite([outpt,'\',outhd,num2str(yr),num2str(mon,'%02d'),'_',sfx,'.tif'],...
                single(m_tmp),Rmat,'GeoKeyDirectoryTag',Rtag)
            fprintf([' ',num2str(mon)])
        end
    end
    fprintf('\n')
end

disp('Finish!')
