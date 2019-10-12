% Caculate the percentage of grass grids in MTE and Jung data.
% LINUX geotiff
% 2017.9.4
tic;close all;clear;clc

%%  input

MCD_fl = '/home/test2/MTE_NEE/JungNEE/clm/MCD12C1.IGBP2000.tif';
GraPrc_fl = '/home/test2/MTE_NEE/OtherData/glc2000_10km_grass_bili.tif';

mnpc = 0.85;

bv = -99;
outpt = '/home/test2/MTE_NEE/JungNEE/BothGraGrid/new';

%%  operate

Gprc = double(imread(GraPrc_fl));
Gprc(Gprc==Gprc(1,1)) = nan;

MCD = double(imread(MCD_fl));
MCD(MCD~=10) = nan;  % 10.grass
MCD = MCD(1:2920,:);  % -56~90 0.05D
MCD = kron(MCD,ones(3,3));

[nrw,ncl] = deal(8760,21600);
S1 = referenceSphere('earth','km');
wdzone = ones(nrw,ncl);
Rmat = makerefmat('RasterSize',[nrw ncl],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');
[~,colarea] = areamat(wdzone,Rmat,S1);
wdarea = repmat(colarea,1,ncl);

disp('start')
[m,n] = deal(1752,4320);
J_gra = nan(m,n);
for ir = 1:m
    for ic = 1:n
        tmp = MCD(1+5*(ir-1):5*ir,1+5*(ic-1):5*ic);
        idx = tmp==10;
        if any(idx(:)) && ~isnan(Gprc(ir,ic))
            ars = wdarea(1+5*(ir-1):5*ir,1+5*(ic-1):5*ic);
            J_gra(ir,ic) = sum(ars(idx))/sum(ars(:));
        end
    end
    disp(num2str(ir))
end

J_gra(J_gra<mnpc) = nan;
Gprc(isnan(J_gra)) = nan;
Gprc(isnan(Gprc)) = bv;
J_gra(isnan(J_gra)) = bv;

Rmat = makerefmat('RasterSize',[m n],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

geotiffwrite([outpt,'/Jung_GraPrc_both_12D_',...
    num2str(mnpc*100),'.tif'],single(J_gra),Rmat)
geotiffwrite([outpt,'/MTE_GraPrc_both_12D_',...
    num2str(mnpc*100),'.tif'],single(Gprc),Rmat)

disp('Finish!')

