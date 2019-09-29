%根据得到每个分区的指标，由txt转成tif
clear;close all;clc %完成matlab程序的初始化工作

disp('start')
%% 输入数据
Zonedata = '/home/Fushuyi/data/zonedata/HG_Tran_Str2010100.txt';%txt数据文件的路径
ZoneGrid = '/home/Fushuyi/data/zonedata/HG_GridCls2010_SN.tif';%分区栅格数据路径
Gridout = '/home/Fushuyi/data/zonedata';%分区指标输出路径

%% 读取数据
zdata = load(Zonedata);
[m,n] = size(zdata);
grid = geotiffread(ZoneGrid);
[x,y] = size(grid);

bv = -9999;%背景值为-9999
Ginfo = geotiffinfo(ZoneGrid);%读取栅格数据的空间参考
Rmat = Ginfo.RefMatrix; %把RefMatrix属性提取出来存储在Rmat；RefMatrix表示必须由GeoTIFF文件明确定义的3×2双引用矩阵。否则为空([])
Rtag = Ginfo.GeoTIFFTags.GeoKeyDirectoryTag; %%GeoTIFFTags表示包含与文件中的GeoTIFF标记匹配的字段名的结构。文件中必须至少有一个GeoTIFF标记，否则将发出错误。

%% 计算
Tssart = nan(x,y);
Nssart = nan(x,y);
Thetaprime = nan(x,y);
Thetabar = nan(x,y);
Ens = nan(x,y);
Es = nan(x,y);

for a=1:1:m
    Tssart(grid==a) = zdata(a,1);
    %Nssart(grid==a) = zdata(a,3);
    %Thetaprime(grid==a) = zdata(a,5);
    %Thetabar(grid==a) = zdata(a,7);
    %Ens(grid==a) = zdata(a,9);
    %Es(grid==a) = zdata(a,11);   
    %disp(['Grids:',num2str(a*100/m),'%'])
end     
Tssart(isnan(Tssart))=bv;
%Nssart(isnan(Nssart))=bv;
%Thetaprime(isnan(Thetaprime))=bv;
%Thetabar(isnan(Thetabar))=bv;
%Ens(isnan(Ens))=bv;
%Es(isnan(Es))=bv;

geotiffwrite([out_path,filesep,'Tssart','.tif'], Tssart,Rmat, 'GeoKeyDirectoryTag',Rtag);
%geotiffwrite([out_path,filesep,'Nssart','.tif'], Nssart,Rmat, 'GeoKeyDirectoryTag',Rtag);
%geotiffwrite([out_path,filesep,'Thetaprime','.tif'], Thetaprime,Rmat, 'GeoKeyDirectoryTag',Rtag);
%geotiffwrite([out_path,filesep,'Thetabar','.tif'], Thetabar,Rmat, 'GeoKeyDirectoryTag',Rtag);
%geotiffwrite([out_path,filesep,'Ens','.tif'], Ens,Rmat, 'GeoKeyDirectoryTag',Rtag);
%geotiffwrite([out_path,filesep,'Es','.tif'], Es,Rmat, 'GeoKeyDirectoryTag',Rtag);
disp('finish')