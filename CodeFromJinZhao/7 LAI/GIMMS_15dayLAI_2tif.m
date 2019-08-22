% GIMMS LAI 15day提取至geotiff
% abl
% 2016.9.17
clear;close all;clc

%%  Input

GMLAI_pt = 'H:\AVHRR_LAI数据\AVHRR_LAI';  % LAI路径

outpt = 'I:\GIMMS_LAI_15day_geotiff\wolrd';  % 结果路径

%%  Operate

Rmat=makerefmat('RasterSize',[2160 4320],...
    'Latlim',[-90 90],'Lonlim',[-180 180],'ColumnsStartFrom','north');
mstr = {'jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'};
hmn = {'a','b'};

for yr = 1982:2011
    for mn = 1:12
        for imn = 1:2
            fid = fopen([GMLAI_pt,'\AVHRRBUVI01.',num2str(yr),mstr{mn},hmn{imn},'.abl'],'r');
            tmp = fread(fid,[2160,4320],'uint8',0,'ieee-be');
            fclose(fid);
            tmp(tmp<0 | tmp>70) = nan;
            tmp = tmp*0.1;
            tmp(isnan(tmp)) = -9999;
            geotiffwrite([outpt,'\GIMMS_',num2str(yr),num2str(mn,'%02d'),hmn{imn},'.tif'],tmp,Rmat)
            
            clc
            disp([num2str([yr,mn]),hmn{imn}])
        end
    end
end

disp('Finish!')
