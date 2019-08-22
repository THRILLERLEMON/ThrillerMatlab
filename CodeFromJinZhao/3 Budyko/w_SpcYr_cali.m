% 率定特殊年份各流域Budyko w值
% EXCEL
% 2016.7.30
clear;close all;clc

%%  Input

xlsfl = 'H:\VI_LP_simu_infat\Budyko校正\82-10胖边界PRP及E0计算n.xlsx';  % 存储某年PRP、E0、ET的xls文件
shnm = 'n';  % 待率定sheet名

wgap = 0.0001;

%%  Operate

tmp = xlsread(xlsfl,shnm);  % PRP E0 ET
rst = nan(2,size(tmp,2));
for bs = 1:length(rst)
    E0 = tmp(2,bs);
    Pr = tmp(1,bs);
    ET = tmp(3,bs);
    
    [w_b,ET_err] = w_best(E0, Pr, ET, wgap);
    rst(:,bs) = [w_b;ET_err];
    
    disp(num2str(bs))
end

xlswrite(xlsfl,{'w';'err'},shnm,'a5')
xlswrite(xlsfl,rst,shnm,'b5')

disp('Finish!')
