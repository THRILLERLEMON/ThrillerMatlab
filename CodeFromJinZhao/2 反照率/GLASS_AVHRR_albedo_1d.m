% Estimate daily blue-sky albedo of LP through GLASS-BSA, GLASS-WSA and AVHRR-SZEN.
% geotiff, 0.05D, LINUX
% 2018.4.27
close all;clear;clc;tic

%%  input

nnodes = 18;
ygap = 5;

BSA_pt = '/home/test2/VImod/GLASS_ABD/LPsq_BSA_1d';
BSA_hd = 'GLASS_BSA_';
BSA_vd = [0,10000];
BSA_sf = 1e-4;

WSA_pt = '/home/test2/VImod/GLASS_ABD/LPsq_WSA_1d';
WSA_hd = 'GLASS_WSA_';
WSA_vd = [0,10000];
WSA_sf = 1e-4;

SZEN_pt = '/home/test2/VImod/AVHRR_SZEN/LPsq_1d';
SZEN_hd = 'AVHRR_SZEN_';
SZEN_vd = [-9000,9000];
SZEN_sf = 1e-2;

[yr1,yr2] = deal(1982,2015);

bv = -99;
outpt = '/home/test2/VImod/GLASS_ABD/LPsq_ABD_1d';

%%  operate

if ~exist(outpt,'dir')
    mkdir(outpt)
end

Gfl = dir([BSA_pt,filesep,'*.tif']);
Gfl = [BSA_pt,filesep,Gfl(1).name];
Ginfo = geotiffinfo(Gfl);
[m,n] = deal(Ginfo.Height,Ginfo.Width);
Rmat = Ginfo.RefMatrix;
Rtag = Ginfo.GeoTIFFTags.GeoKeyDirectoryTag;

mons = [31,28,31,30,31,30,31,31,30,31,30,31];
parobj = parpool('local',nnodes);
for yr = yr1:yr2
    mons1 = mons;
    if mod(yr,400)==0||(mod(yr,4)==0 && mod(yr,100)~=0)
        mons1(2) = 29;
    end
    parfor idoy = 1:sum(mons1)
        BSA_vd1=BSA_vd; WSA_vd1=WSA_vd; SZEN_vd1=SZEN_vd; ygap1 = ygap;
        mons2 = [0,cumsum(mons1)];
        imn = find(idoy>mons2,1,'last');
        idy = idoy-mons2(imn);
        if idoy==366
            ygap1 = ygap1+7;
        end
        yra1=max([yr-ygap1,yr1]); yra2=min([yr+ygap1,yr2]);
        ABDref = nan(m,n,yra2-yra1+1);
        for yra = yra1:yra2
            BSA_fl = dir([BSA_pt,filesep,BSA_hd,num2str(yra),...
                num2str(idoy,'%03d'),'*.tif']);
            if ~isempty(BSA_fl)
                BSA = double(imread([BSA_pt,filesep,BSA_fl.name]));
                BSA(BSA<BSA_vd1(1)|BSA>BSA_vd1(2)) = nan;
                BSA = BSA*BSA_sf;
                
                WSA_fl = dir([WSA_pt,filesep,WSA_hd,num2str(yra),...
                    num2str(idoy,'%03d'),'*.tif']);
                WSA = double(imread([WSA_pt,filesep,WSA_fl.name]));
                WSA(WSA<WSA_vd1(1)|WSA>WSA_vd1(2)) = nan;
                WSA = WSA*WSA_sf;
                
                SZEN_fl = dir([SZEN_pt,filesep,SZEN_hd,num2str(yra),...
                    num2str(idoy,'%03d'),'*.tif']);
                SZEN = double(imread([SZEN_pt,filesep,SZEN_fl.name]));
                SZEN(SZEN<SZEN_vd1(1)|SZEN>SZEN_vd1(2)) = nan;
                SZEN = SZEN*SZEN_sf;
                
                % blue-sky albedo
                fdif = 0.123*cosd(SZEN).^(-0.8425);
                fdir = 1-fdif;
                ABD = fdir.*BSA + fdif.*WSA;
                
                ABDref(:,:,yra-yra1+1) = ABD;
            end
        end
        ABDrl = ABDref(:,:,yr-yra1+1)
        ABDref = nanmean(ABDref,3);
        idx = find(isnan(ABDrl) & ~isnan(ABDref));
        ABDrl(idx) = ABDref(idx);
        
        ABDrl = round(ABDrl*1e4);
        ABDrl(isnan(ABDrl)) = bv;
        geotiffwrite([outpt,filesep,'GLASS_AVHRR_BlueSkyAlbedo_',...
            num2str(yr),num2str(idoy,'%03d'),'_',...
            num2str(imn,'%02d'),num2str(idy,'%02d'),'.tif'],...
            int16(ABDrl),Rmat,'GeoKeyDirectoryTag',Rtag)
        disp([num2str(yr),' ',num2str(idoy)])
    end
end
delete(parobj);
mins = toc;
disp(['Time:',num2str(mins/60),'mins'])
