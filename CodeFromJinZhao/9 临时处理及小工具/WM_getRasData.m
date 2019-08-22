% 提取栅格数据
% 两幅栅格行列号必须一致
% geotiff
% JZ 2017.4.12
clear;close all;clc

%%  input

obv_fl = '';  % 观测结果
bv1 = -99;  % 观测结果背景值

modl_fl = ''; % 模拟结果
bv2 = -99;  % 模拟结果背景值

outpt = '';  % 输出路径

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
