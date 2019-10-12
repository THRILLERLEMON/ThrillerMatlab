% Determine the change of NEE in stage before 2000 raletive to the previous stage.
% geotiff
% 2017.5.11

%  Ss-Ss:3
%  Ss-Sk:-3
%  Sk-Ss:1
%  Sk-Sk:-1

clear;close all;clc

%%  input

NEEave_pt = '/home/test2/MTE_NEE/NEE_new02/ymean';

outpt = '/home/test2/MTE_NEE/NEE_new02/PsNg_year';

%%  operate

NEEbf = double(imread([NEEave_pt,'/NEEfluxsum_82to99_mean.tif']));
NEEbf(NEEbf==NEEbf(1,1)) = nan;

NEEaf = double(imread([NEEave_pt,'/NEEfluxsum_00to12_mean.tif']));
NEEaf(NEEaf==NEEaf(1,1)) = nan;

[m,n] = deal(1752,4320);
Rmat = makerefmat('RasterSize',[m n],...
    'Latlim',[-56 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

rst = nan(m,n);
for ir = 1:m
    for ic = 1:n
        bf = NEEbf(ir,ic);
        af = NEEaf(ir,ic);
        if ~isnan(bf+af)
            sbf = sign(bf);
            saf = sign(af);
            rst(ir,ic) = sbf*saf+2*saf;
        end
    end
    disp(num2str(ir))
end

rst(isnan(rst)) = -99;
geotiffwrite([outpt,'/NEE_SsSkChg_2000s.tif'],int8(rst),Rmat);

disp('Finish!')
