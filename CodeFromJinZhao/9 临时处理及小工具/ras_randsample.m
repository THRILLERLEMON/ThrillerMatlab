% դ���������ȡ�㣬���������TXT�ļ�
% geotiff

clear;close all;clc

%%  user

ras_file = 'E:\��̬ϵͳ-ֲ��\�Ӻӻ�����ģ������\YH_gridclass.tif';  % դ�������ļ�
valid = [0, 300];  % դ��������Ч��Χ
smpnum = 100;  % ���ѡ�����
outtxt = 'E:\��̬ϵͳ-ֲ��\�Ӻӻ�����ģ������\���ѡ����.txt';

%%  calculate

rasfl = double(imread(ras_file));
rasfl(rasfl < valid(1) | rasfl > valid(2)) = nan;

rasvd = rasfl(~isnan(rasfl));
idxsm = randperm(length(rasfl(~isnan(rasfl))), smpnum);

dlmwrite(outtxt, rasvd(idxsm))

disp('OK!')