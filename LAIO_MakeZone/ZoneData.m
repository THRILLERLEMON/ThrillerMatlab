%���ݵõ�ÿ��������ָ�꣬��txtת��tif
clear;close all;clc %���matlab����ĳ�ʼ������

disp('start')
%% ��������
Zonedata = '/home/Fushuyi/data/zonedata/HG_Tran_Str2010100.txt';%txt�����ļ���·��
ZoneGrid = '/home/Fushuyi/data/zonedata/HG_GridCls2010_SN.tif';%����դ������·��
Gridout = '/home/Fushuyi/data/zonedata';%����ָ�����·��

%% ��ȡ����
zdata = load(Zonedata);
[m,n] = size(zdata);
grid = geotiffread(ZoneGrid);
[x,y] = size(grid);

bv = -9999;%����ֵΪ-9999
Ginfo = geotiffinfo(ZoneGrid);%��ȡդ�����ݵĿռ�ο�
Rmat = Ginfo.RefMatrix; %��RefMatrix������ȡ�����洢��Rmat��RefMatrix��ʾ������GeoTIFF�ļ���ȷ�����3��2˫���þ��󡣷���Ϊ��([])
Rtag = Ginfo.GeoTIFFTags.GeoKeyDirectoryTag; %%GeoTIFFTags��ʾ�������ļ��е�GeoTIFF���ƥ����ֶ����Ľṹ���ļ��б���������һ��GeoTIFF��ǣ����򽫷�������

%% ����
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