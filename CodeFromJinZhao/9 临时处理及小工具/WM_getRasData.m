% ��ȡդ������
% ����դ�����кű���һ��
% geotiff
% JZ 2017.4.12
clear;close all;clc

%%  input

obv_fl = '';  % �۲���
bv1 = -99;  % �۲�������ֵ

modl_fl = ''; % ģ����
bv2 = -99;  % ģ��������ֵ

outpt = '';  % ���·��

%%  operate

obv = double(imread(obv_fl));
obv(obv==bv1) = nan;
obv = obv(:);

modl = double(imread(modl_fl));
modl(modl==bv2) = nan;
modl = modl(:);

idx = find(isnan(obv) | isnan(modl));

obv(idx) = [];
modl(idx) = [];

[rv,pv] = corrcoef(obv,modl);

% dlmwrite([outpt,'\Obv_grids.txt'],obv,'delimiter',' ','precision','%9f')
% dlmwrite([outpt,'\Modl_grids.txt'],modl,'delimiter',' ','precision','%9f')
dlmwrite([outpt,'\P_R.txt'],[rv(2,1);pv(2,1)],'delimiter',' ','precision','%9f')

disp('Finish!')
