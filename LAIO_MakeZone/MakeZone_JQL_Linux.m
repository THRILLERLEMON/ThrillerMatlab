%%%%  thriller 2018-11-14  %%%%
%todo 1 % 在landcover数据中分出人工林和自然林
%todo 2 % 有dem来考虑坡位
%% 根据土壤类型；α，λ梯度变化；坡度、坡向来分块

clear;close all;clc

Soiltp = '/home/JiQiulei/LAIO_makezone/HWSD_LP_WGS1984_90m/HWSD_LP_90m_masked.tif';  % 土壤类型空间数据
Soil_vd = [11020,11934];  % 土壤类型数据有效值范围

Alpha = '/home/JiQiulei/LAIO_makezone/AlpLmd_ave_90mmasked/LP_Alpha_00to12_9090masked.tif';  % α数据
Alpha_vd = [0,100];  % α数据有效范围

Lamda = '/home/JiQiulei/LAIO_makezone/AlpLmd_ave_90mmasked/LP_Lamda_00to12_9090masked.tif';  % λ数据
Lamda_vd = [0,1];  % λ数据有效范围

Vegm = '/home/JiQiulei/LAIO_makezone/Landcover2010_90m_masked/landcover2010_90m_masked.tif';  %植被类型空间数据
Vegm_vd = [101,607];  % λ数据有效范围

DemSRTM = '/home/JiQiulei/LAIO_makezone/srtm_lp_wgs1984_90m/srtm_lp_90m_masked.tif';  %DEM数据
DemSRTM_vd = [87,5206];  %DEM数据变化梯度

bv = -9999;  % 输出结果背景值
clsgrid_out = '/home/JiQiulei/LAIO_makezone/Zone/HG_GridCls2010.txt';  % 输出分类格点编号空间结果
clslist_out = '/home/JiQiulei/LAIO_makezone/Zone/HG_Clslist2010.txt';  % 分类组合列表

%%  calculate

soil = double(imread(Soiltp));
soil(soil<Soil_vd(1) | soil>Soil_vd(2)) = nan;
soil(isnan(Vegm)) = nan;

alpha = double(imread(Alpha));
alpha(alpha<Alpha_vd(1) | alpha>Alpha_vd(2)) = nan;
alpha(isnan(Vegm)) = nan;
alpha_gt = 5;  % alpha变化梯度 mm 原来是0.1

lamda = double(imread(Lamda));
lamda(lamda<Lamda_vd(1) | lamda>Lamda_vd(2)) = nan;
lamda(isnan(Vegm)) = nan;
lamda_gt = 0.25;  % lamda变化梯度 原来是0.01

dem = double(imread(DemSRTM));
dem(dem<DemSRTM_vd(1) | dem>DemSRTM_vd(2)) = nan;
refvec = [1200,0,0];  %这里定义的向量第一个元素1200是cells/degree（应为是90m分辨率的数据）
[asp,slp] = gradientm(dem,refvec);  %计算坡向、坡度
asp(asp<0 | asp>360) = nan;
asp(isnan(Vegm)) = nan;
slp(slp<0 | slp>90) = nan;
slp(isnan(Vegm)) = nan;

%%  range
soil_rg = unique(soil);
soil_rg(isnan(soil_rg)) = [];

alpha_rg = min(alpha(:)):alpha_gt:max(alpha(:)) + alpha_gt;
lamda_rg = min(lamda(:)):lamda_gt:max(lamda(:)) + lamda_gt;

asp_rg = [0,45,90,135,180,225,270,315,360];
slp_rg = [0,30,60,90];

%%  out
clsgrid = nan(size(soil,1),size(soil,2));
clslist = [];
IDz = 0;

for isoi = 1:length(soil_rg)
    for ialp = 1:length(alpha_rg)-1
        for ilam = 1:length(lamda_rg)-1
            for iasp = 1:8
                for islp = 1:3
                        idx = find(soil==soil_rg(isoi) & ...
                        (alpha>=alpha_rg(ialp) & alpha<alpha_rg(ialp+1)) & ...
                        (lamda>=lamda_rg(ilam) & lamda<lamda_rg(ilam+1)) & ...
                        (asp>=asp_rg(iasp) & asp<asp_rg(iasp+1)) & ...
                        (slp>=slp_rg(islp) & slp<slp_rg(islp+1)));
                    if ~isempty(idx)
                        IDz = IDz+1;
                        clsgrid(idx) = IDz;
                        clslist = cat(1,clslist, ...
                            [IDz,mean(alpha(idx)),mean(lamda(idx)),nanmean(asp(idx)),nanmean(slp(idx)),soil_rg(isoi)]);
                    end
                end
            end
        end
    end
    clc
    disp(['process:',num2str(isoi*100/length(soil_rg)),'%'])
end

clsgrid(isnan(clsgrid)) = bv;

dlmwrite(clsgrid_out,clsgrid)

dlmwrite(clslist_out,clslist)

disp('Finish!')
