% Find the maximum of R between NEE and GPP and Re.
% geotiff LINUX
% 2017.8.31
tic;close all;clear;clc

%%  input

RP_pt = '/home/test2/MTE_NEE/NEE_new02/Cor/GPP_Re';

clmgs_fl = '/home/test2/MTE_NEE/OtherData/Gras_Clim.tif';  % climate of grassland
grabl_fl = '/home/test2/MTE_NEE/OtherData/glc2000_10km_grass_bili.tif';

bv = -99;
outpt = '/home/test2/MTE_NEE/NEE_new02/Cor/GPP_Re/stats';

%%  operate

[m,n] = deal(1752,4320);
Rmat = makerefmat('RasterSize',[m n],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

GPP_r = double(imread([RP_pt,'/GPP_NEE_dtrd_R.tif']));
GPP_r(GPP_r==GPP_r(1,1)) = nan;
GPP_p = double(imread([RP_pt,'/GPP_NEE_dtrd_P.tif']));
GPP_p(GPP_p==GPP_p(1,1)) = nan;
Re_r = double(imread([RP_pt,'/Re_NEE_dtrd_R.tif']));
Re_r(Re_r==Re_r(1,1)) = nan;
Re_p = double(imread([RP_pt,'/Re_NEE_dtrd_P.tif']));
Re_p(Re_p==Re_p(1,1)) = nan;

idn = isnan(GPP_r+Re_r);

GPP_rsg = GPP_r;
GPP_rsg(GPP_p>0.05) = nan;
Re_rsg = Re_r;
Re_rsg(Re_p>0.05) = nan;

Rsgs = cat(3,GPP_rsg,Re_rsg);
[~,Mx_sg] = max(abs(Rsgs),[],3);
Mx_sg(idn) = nan;

Rs = cat(3,GPP_r,Re_r);
[~,Mx] = max(abs(Rs),[],3);
Mx(idn) = nan;

disp('Max R')
MxVr = nan(m,n);
MxVrsg = nan(m,n);
for ir = 1:m
    for ic = 1:n
        if ~isnan(Mx(ir,ic))
            MxVr(ir,ic) = sign(Rs(ir,ic,Mx(ir,ic)))*Mx(ir,ic);
            if ~isnan(Mx_sg(ir,ic))
                MxVrsg(ir,ic) = sign(Rsgs(ir,ic,Mx_sg(ir,ic)))*Mx_sg(ir,ic);
            end
        end
    end
    disp(num2str(ir))
end
MxVr(isnan(MxVr)) = bv;
MxVrsg(isnan(MxVrsg)) = bv;
geotiffwrite([outpt,'/NEE_GPP_Re_dtrd_Rmax.tif'],int8(MxVr),Rmat)
geotiffwrite([outpt,'/NEE_GPP_Re_dtrd_Rmaxsg.tif'],int8(MxVrsg),Rmat)

disp('Stats')
clmgs = double(imread(clmgs_fl));
clmgs(clmgs==clmgs(1,1)) = nan;
clmgs2 = clmgs(:);
clmgs2(isnan(clmgs2)) = [];
uqclm = unique(clmgs2(:));
clearvars clmgs2

S1 = referenceSphere('earth','km');
wdzone = ones(1752,4320);
Rmat = makerefmat('RasterSize',[1752 4320],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');
[~,colarea] = areamat(wdzone,Rmat,S1);
wdarea = repmat(colarea,1,4320);

grabl = double(imread(grabl_fl));
grabl(grabl==grabl(1,1)) = nan;

wdar_gr = wdarea.*grabl;
wdar_gr1 = wdar_gr;
wdar_gr1(isnan(Mx)) = nan;
wdar_gr2 = wdar_gr;
wdar_gr2(isnan(Mx_sg)) = nan;

rst = nan(length(uqclm),5,2);
rst_sg = nan(length(uqclm),5,2);
for clm = 1:length(uqclm)
    ar_zn = nansum(wdar_gr1(clmgs==uqclm(clm)));
    ar_gpp_ps = nansum(wdar_gr1(clmgs==uqclm(clm) & MxVr==1));
    ar_gpp_ng = nansum(wdar_gr1(clmgs==uqclm(clm) & MxVr==-1));
    ar_re_ps = nansum(wdar_gr1(clmgs==uqclm(clm) & MxVr==2));
    ar_re_ng = nansum(wdar_gr1(clmgs==uqclm(clm) & MxVr==-2));
    
    rst(clm,:,1) = [ar_gpp_ps,ar_gpp_ng,ar_re_ps,ar_re_ng,ar_zn];
    rst(clm,:,2) = [ar_gpp_ps*100/ar_zn,ar_gpp_ng*100/ar_zn,...
        ar_re_ps*100/ar_zn,ar_re_ng*100/ar_zn,ar_zn*100/ar_zn];
    
    ar_zn = nansum(wdar_gr2(clmgs==uqclm(clm)));
    ar_gpp_ps = nansum(wdar_gr2(clmgs==uqclm(clm) & MxVrsg==1));
    ar_gpp_ng = nansum(wdar_gr2(clmgs==uqclm(clm) & MxVrsg==-1));
    ar_re_ps = nansum(wdar_gr2(clmgs==uqclm(clm) & MxVrsg==2));
    ar_re_ng = nansum(wdar_gr2(clmgs==uqclm(clm) & MxVrsg==-2));
    
    rst_sg(clm,:,1) = [ar_gpp_ps,ar_gpp_ng,ar_re_ps,ar_re_ng,ar_zn];
    rst_sg(clm,:,2) = [ar_gpp_ps*100/ar_zn,ar_gpp_ng*100/ar_zn,...
        ar_re_ps*100/ar_zn,ar_re_ng*100/ar_zn,ar_zn*100/ar_zn];
end

dlmwrite([outpt,'/NEE_CorCtr_Area.txt'],[uqclm,rst(:,:,1)],'delimiter',' ')
dlmwrite([outpt,'/NEE_CorCtr_AreaPrc.txt'],[uqclm,rst(:,:,2)],'delimiter',' ')
dlmwrite([outpt,'/NEE_CorSgCtr_Area.txt'],[uqclm,rst_sg(:,:,1)],'delimiter',' ')
dlmwrite([outpt,'/NEE_CorSgCtr_AreaPrc.txt'],[uqclm,rst_sg(:,:,2)],'delimiter',' ')

disp('Finish!')

