% Get Grass Grid Info
% Windows 10 1903
% 2019.9.27
% JiQiulei thrillerlemon@outlook.com
close all;clear;clc

%%  input 
% 1/2
grass_pt= 'E:\OFFICE\MTE_NEE_DATA\GetGrassGridInfo_Zhang\glc2000_0.5du_grass.tif';
grassmask=geotiffread(grass_pt);
% 1/2
tem_pt = 'E:\OFFICE\MTE_NEE_DATA\GetGrassGridInfo_Zhang\temperature_1982-2013year_mean.tif';
tem = geotiffread(tem_pt);
tem(tem==tem(1,1)) = nan;
tem(tem>300) = nan;
% 1/2
pre_pt = 'E:\OFFICE\MTE_NEE_DATA\GetGrassGridInfo_Zhang\precipitation_1982-2013year_mean.tif';
pre = geotiffread(pre_pt);
pre(pre==pre(1,1)) = nan;

[rows,cols]=size(grassmask);
%9999=tem 0000=pre
result = [9999,-9999];

temp = NaN(1,2);
for j = 1:rows
    for jj = 1:cols
        if grassmask(j, jj) == 1
            temp(1,1) = tem(j, jj);
            temp(1,2) = pre(j, jj);
            if ~(isnan(temp(1,1)) || isnan(temp(1,2)))
                result=[result;temp];
            end
        end
    end
end
csvwrite('E:\OFFICE\MTE_NEE_DATA\GetGrassGridInfo_Zhang\GetGrassGridInfo_Zhang.csv', result);
disp('ok')