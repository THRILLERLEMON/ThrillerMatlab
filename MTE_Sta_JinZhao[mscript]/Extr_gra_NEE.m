% Extract grass grids of mean annual NEE from Jung and MTE.
% 2017.4.17
clear;close all;clc

%%  input

MTE_NEE_fl = '/home/test2/MTE_NEE/NEE_new/ymean/NEEgraTotal_82to11_mean.tif';
grabl_fl = '/home/test2/MTE_NEE/OtherData/glc2000_10km_grass_bili.tif';

Jung_NEE_ANN_fl = '/home/test2/MTE_NEE/JungNEE/ymean/Jung_NEE_FLUX_ANN_82to11_mean.tif';
Jung_NEE_RF_fl = '/home/test2/MTE_NEE/JungNEE/ymean/Jung_NEE_FLUX_RF_82to11_mean.tif';
JungClm_fl = '/home/test2/MTE_NEE/JungNEE/clm/MCD12C1.A2010001.051.2012264191019.tif';

gra_st_fl = '/home/test2/MTE_NEE/OtherData/Gra_LatLon.txt';

outpt = '/home/test2/MTE_NEE/NEE_new/Data_contrast';

%%  operate

[m,n] = deal(292,720);

NEEm = double(imread(MTE_NEE_fl));  % 1/12 1752 4320
NEEm(NEEm==NEEm(1,1)) = nan;

grabl = double(imread(grabl_fl));
grabl(grabl==grabl(1,1)) = nan;

S1 = referenceSphere('earth','km');
wdzone = ones(1752,4320);
Rmat = makerefmat('RasterSize',[1752 4320],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');
[~,colarea] = areamat(wdzone,Rmat,S1);
wdarea = repmat(colarea,1,4320);

NEEjann = double(imread(Jung_NEE_ANN_fl));  % 0.5 360 720
NEEjann(NEEjann==NEEjann(1,1)) = nan;
NEEjann = NEEjann(1:292,:);

NEEjrf = double(imread(Jung_NEE_RF_fl));  % 0.5 360 720
NEEjrf(NEEjrf==NEEjrf(1,1)) = nan;
NEEjrf = NEEjrf(1:292,:);

CLMj = double(imread(JungClm_fl));  % 0.05 3600 7200
CLMj(CLMj==CLMj(1,1)) = nan;  % 10 grass
CLMj = CLMj(1:2920,:);

graST = dlmread(gra_st_fl);

NEE05 = nan(m,n);
MTEpc = nan(m,n);
Jpc = nan(m,n);
rst90 = [];
rstST = [];
for ir = 1:m
    for ic = 1:n
        iNEEm = NEEm((ir-1)*6+1:ir*6,(ic-1)*6+1:ic*6);
        if any(~isnan(iNEEm(:)))
            iwdarea = wdarea((ir-1)*6+1:ir*6,(ic-1)*6+1:ic*6);
            iwdarea(isnan(iNEEm)) = nan;
            igrabl = grabl((ir-1)*6+1:ir*6,(ic-1)*6+1:ic*6);
            
            iNEEmflx = nansum(iNEEm(:))*10^9/nansum(iwdarea(:).*igrabl(:));
            NEE05(ir,ic) = iNEEmflx;
            
            MTEpc(ir,ic) = sum(~isnan(iNEEm(:)))/36;
            
            iCLMj = CLMj((ir-1)*10+1:ir*10,(ic-1)*10+1:ic*10);
            if sum(iCLMj(:)==10)>0
                Jpc(ir,ic) = sum(iCLMj(:)==10)/100;
            end
            if sum(~isnan(iNEEm(:)))/36 >= 0.7
                % iCLMj = CLMj((ir-1)*10+1:ir*10,(ic-1)*10+1:ic*10);
                if sum(iCLMj(:)==10)/100 >= 0.7
                    rst90 = cat(1,rst90,[ir,ic,iNEEmflx,...
                        NEEjann(ir,ic),NEEjrf(ir,ic)]);  % row col MTE ANN RF
                    lats = [90-0.5*(ir-1),90-0.5*ir];
                    lons = [-180+0.5*(ic-1),-180+0.5*ic];
                    for ist = 1:length(graST)
                        if (graST(ist,2)>=lats(2) && graST(ist,2)<lats(1)) &&...
                                (graST(ist,3)>=lons(1) && graST(ist,3)<lons(2))
                            rstST = cat(1,rstST,...
                                [graST(ist,1),ir,ic,iNEEmflx,NEEjann(ir,ic),NEEjrf(ir,ic)]);
                        end
                    end
                end
            end
        end
        if ~isempty(rstST)
            rstST = sortrows(rstST,1);
        end
    end
    disp(num2str(ir))
end

Rmat1 = makerefmat('RasterSize',[292 720],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

dlmwrite([outpt,'/NEE90.txt'],rst90,'delimiter',' ')
if ~isempty(rstST)
    dlmwrite([outpt,'/NEEgra.txt'],rstST,'delimiter',' ')
end

NEE05(isnan(NEE05)) = -9999;
geotiffwrite([outpt,'/NEEflux05_82to11_mean.tif'],single(NEE05),Rmat1)

MTEpc(isnan(MTEpc)) = -9999;
geotiffwrite([outpt,'/MTE_gra_prc.tif'],single(MTEpc),Rmat1)

Jpc(isnan(Jpc)) = -9999;
geotiffwrite([outpt,'/Jung_gra_prc.tif'],single(Jpc),Rmat1)

disp('Finish!')

