close all;clear;clc
H=load('C:\Users\thril\Desktop\��ԭ��ʦ����ʦ��������\age_map.mat');
cellarry=struct2cell(H);
arry=cell2mat(cellarry);
[m,n]=size(arry);
outpt1='C:\Users\thril\Desktop\��ԭ��ʦ����ʦ��������\age_map.tif';

Rm=[0 ,-40/m;
        70/n ,0;
        70 ,55 ];
arry(isnan(arry))=-99;
arry(arry>10000)=-99;
geotiffwrite(outpt1, uint16(arry),Rm,'CoordRefSysCode', 4326);