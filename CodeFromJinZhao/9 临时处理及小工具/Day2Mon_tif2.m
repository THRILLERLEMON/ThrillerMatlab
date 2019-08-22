% geotiff日数据合成月数据
% 根据日期信息计算月数据，日期信息“2008056”
% JZ 2018.1.28
clear all;clc;close all

%%  user
raspath = 'E:\R\Raster_test\EVI_day';    % Monthly rasters'document

heads = 'MOD13A3.A'; % 文件名年份前字符串
valid = [-2000,10000];  % 数据有效范围
sf= 0.0001;  % scale factor

ygap = [2000,2005];   % 起止年份
mgap = [4,10]; % 起止月份

stats = 1;  % 月数据合成方式 1：均值 2：最大值 3：最小值 4：总和
outbv = -9999; % result's backvalue
outpath = 'E:\R\Raster_test\raster_day2mon_resutl\matlab';   % 输出路径

%%  calculate
mon_p = [31,28,31,30,31,30,31,31,30,31,30,31];
mon_r = [31,29,31,30,31,30,31,31,30,31,30,31];

ynum = length(heads) + 1;
for ys = ygap(1):ygap(2)
    disp(num2str(ys))
    if mod(ys,400)==0 || (mod(ys,4)==0 && mod(ys,100)~=0)
        mons1 = mon_r;
    else
        mons1 = mon_p;
    end
    mons2 = cumsum(mons1);
    
    tfs = dir([raspath,'\',heads,num2str(ys),'*.tif']);
    Ginfo = geotiffinfo([raspath,'\',tfs(1).name]);
    Rmat = Ginfo.RefMatrix;
    
    for mon = mgap(1):mgap(2)
        m_tmp = [];
        for fl = 1:length(tfs)
            if find(mons2>=str2double(tfs(fl).name(ynum+4:ynum+6)),1,'first')==mon
                tmp = double(imread([raspath,'\',tfs(fl).name]));
                tmp(tmp<valid(1)|tmp>valid(2)) = nan;
                tmp = tmp*sf;
                m_tmp = cat(3,m_tmp,tmp);
            end
        end
        if ~isempty(m_tmp)
            switch stats
                case 1
                    rst = nanmean(m_tmp,3);
                    outsuffix = '_ave.tif';
                case 2
                    rst = nanmax(m_tmp,[],3);
                    outsuffix = '_max.tif';
                case 3
                    rst = nanmin(m_tmp,[],3);
                    outsuffix = '_min.tif';
                case 4
                    rst = nansum(m_tmp,3);
                    outsuffix = '_sum.tif';
            end
            
            rst(isnan(rst)) = outbv;
            geotiffwrite([outpath,'\',heads,num2str(ys),num2str(mon,'%02d'),outsuffix],...
                         single(rst),Rmat,'GeoKeyDirectoryTag',Ginfo.GeoTIFFTags.GeoKeyDirectoryTag)
            disp(num2str(mon))
        end
    end
end
disp('OK')
