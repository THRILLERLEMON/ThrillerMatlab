clear;clc
%% calculate NEE

%% mat directory
load '/home/JiQiulei/MTE_JQL_2019/MTE_RunRes/bestMTE.mat'

%% static
MAT_path = '/home/LiShuai/Data/MA_temperature'; % Mean annual Temperature 
MAPre_path = '/home/LiShuai/Data/MA_precipitation_sum'; % Mean annual Precipetation sum
MACWB_path = '/home/LiShuai/Data/MA_climatic_water_balance'; % Mean annual Climatic water balance
MAPET_path = '/home/LiShuai/Data/MA_potential_evapotranspiration'; % Mean annual Potential evaporation
MAIR_path = '/home/LiShuai/Data/MA_incoming_radiation'; % Mean annual Incoming radiation
MARH_path = '/home/LiShuai/Data/MA_relative_humidity'; % Mean annual relative humidity
GSL_path = '/home/LiShuai/Data/growlength_year'; % Growing season length derived from fAPAR
IGBP_path = '/home/LiShuai/Data/IGBP_veg_type/GIGBP_Resemble_10KM'; % vegetation type

GSOC_path = '/home/JiQiulei/MTE_JQL_2019/NewAddData/GSOC'; % new add by JQL global soil organic carbon
elevation_path = '/home/JiQiulei/MTE_JQL_2019/NewAddData/elevation_MERIT_10km'; % new add by JQL dem elevation
slope_path = '/home/JiQiulei/MTE_JQL_2019/NewAddData/slope_MERIT_10km'; % new add by JQL dem slope
tpi_path = '/home/JiQiulei/MTE_JQL_2019/NewAddData/tpi_MERIT_10km'; % new add by JQL dem topographic index
twi_path = '/home/JiQiulei/MTE_JQL_2019/NewAddData/twi_MERIT_10km'; % new add by JQL dem topographic wetness index
vbf_path = '/home/JiQiulei/MTE_JQL_2019/NewAddData/vbf_MERIT_10km'; % new add by JQL dem valley bottom index

%% month but static over the year
MMT_path = '/home/LiShuai/Data/MM_temperature'; % Mean monthly temperature
MMPre_path = '/home/LiShuai/Data/MM_precipitation'; % Mean monthly Precipetation sum
MMCWB_path = '/home/LiShuai/Data/MM_climatic_water_balance'; % Mean monthly Climatic water balance
MMPET_path = '/home/LiShuai/Data/MM_potential_evapotranspiration'; % Mean monthly Potential evaporation
MMIR_path = '/home/LiShuai/Data/MM_incoming_radiation'; % Mean monthly Incoming radiation
MMRH_path = '/home/LiShuai/Data/MM_relative_humidity'; % Mean monthly relative humidity
MMSR_path = '/home/LiShuai/Data/MM_short_radiation'; % Mean monthly Short radiation

%% year
MaxFY_path = '/home/LiShuai/Data/fapar_year_max'; % Maxinum fAPAR of year 
MinFY_path = '/home/LiShuai/Data/fapar_year_min'; % Minimum fAPAR of year
MA_F_path = '/home/LiShuai/Data/MA_FAPAR1'; % Mean annual fAPAR
SumFG_path = '/home/LiShuai/Data/sumfapar_growseason_year'; % Sum of fAPAR over the growing season
SF_SR_path = '/home/LiShuai/Data/sumfapar_growseason.shortR_year'; % Sum of fAPAR * Short radiation of year
MeanFG_path = '/home/LiShuai/Data/meanfapar_growseason_year'; % Mean fAPAR of the growing season
MaxF_SR_path = '/home/LiShuai/Data/maxfapar.shortR_year'; % Maximum of fAPAR * Short radiation of year
Intensive_frac_path = '/home/LiShuai/Data/Grass_Management/Intensive_frac'; %intensive fraction

Manure_path = '/home/JiQiulei/MTE_JQL_2019/NewAddData/Manure_Application1982_2011'; %new add by JQL Manure_Application
Nfertilizer_path = '/home/JiQiulei/MTE_JQL_2019/NewAddData/Nfertilizer_Application1982_2011'; %new add by JQL Nfertilizer Application
NDeposition_path = '/home/JiQiulei/MTE_JQL_2019/NewAddData/N_Deposition1982_2011'; %new add by JQL N_Deposition

%% month
MT_path = '/home/LiShuai/Data/tem'; % Monthly Temperature
MPre_path = '/home/LiShuai/Data/pre'; % Monthly Precipitation
FrostD_path = '/home/LiShuai/Data/Frost_day_frequency'; %frost_day_frequncy
WetD_path = '/home/LiShuai/Data/Wet_day_frequency'; % wet days frequncy
LR_path = '/home/LiShuai/Data/Long_Radiation_month/day_sum'; %Monthly Long Radiation
MF_path = '/home/LiShuai/Data/fapar_month'; % Monthly fAPAR
MF_MSR_path = '/home/LiShuai/Data/fapar.shortR_month'; % Monthly fAPAR * Short radiation
Tem_max_path = '/home/LiShuai/Data/tem_max'; %Month temperature max
Tem_min_path = '/home/LiShuai/Data/tem_min'; %Month temperature min
Soil_Tem_path = '/home/LiShuai/Data/Soil_Temperature'; %Month Soil temperature
Soil_Moisture_path = '/home/LiShuai/Data/Soil_Moisture'; %Month Soil Moisture
Three_LAI_path = '/home/LiShuai/Data/three_lai_mean_month'; %LAI  mean of three products
ABD_path = '/home/LiShuai/Data/global_abd_month'; % abedo month
EMT_path = '/home/LiShuai/Data/global_EMT_month'; %EMT month
CO2_path = '/home/LiShuai/Data/198201-201112_co2.xlsx'; %CO2 month
%V_P_path = '/home/LiShuai/Data/Vapour_pressure'; % vapoure pressure
%Wind_path = '/home/LiShuai/Data/Wind'; %all wind 

%% outpath
NEE_outpath = '/home/JiQiulei/MTE_JQL_2019/NEE_Upscale_PART';
out_prefix = '_global_grass_NEE';% the name after year_month
out_bv = -9999;     %set the backvalue

%% read
imnames_MAT = dir(fullfile(MAT_path,'/','*.tif'));
imnames_MAPre = dir(fullfile(MAPre_path,'/','*.tif'));
imnames_MACWB = dir(fullfile(MACWB_path,'/','*.tif'));
imnames_MAPET = dir(fullfile(MAPET_path,'/','*.tif'));
imnames_MAIR = dir(fullfile(MAIR_path,'/','*.tif'));
imnames_MARH = dir(fullfile(MARH_path,'/','*.tif'));
imnames_GSL = dir(fullfile(GSL_path,'/','*.tif'));
imnames_IGBP = dir(fullfile(IGBP_path,'/','*.tif'));

%add by JQL
imnames_GSOC = dir(fullfile(GSOC_path,'/','*.tif'));
imnames_elevation = dir(fullfile(elevation_path,'/','*.tif'));
imnames_slope = dir(fullfile(slope_path,'/','*.tif'));
imnames_tpi = dir(fullfile(tpi_path,'/','*.tif'));
imnames_twi = dir(fullfile(twi_path,'/','*.tif'));
imnames_vbf = dir(fullfile(vbf_path,'/','*.tif'));

imnames_MMT = dir(fullfile(MMT_path,'/','*.tif'));
imnames_MMPre = dir(fullfile(MMPre_path,'/','*.tif'));
imnames_MMCWB = dir(fullfile(MMCWB_path,'/','*.tif'));
imnames_MMPET = dir(fullfile(MMPET_path,'/','*.tif'));
imnames_MMRH = dir(fullfile(MMRH_path,'/','*.tif'));
imnames_MMIR = dir(fullfile(MMIR_path,'/','*.tif'));
imnames_MMSR = dir(fullfile(MMSR_path,'/','*.tif'));

imnames_MaxFY = dir(fullfile(MaxFY_path,'/','*.tif'));
imnames_MinFY = dir(fullfile(MinFY_path,'/','*.tif'));
imnames_MA_F = dir(fullfile(MA_F_path,'/','*.tif'));
imnames_SumFG = dir(fullfile(SumFG_path,'/','*.tif'));
imnames_SF_SR = dir(fullfile(SF_SR_path,'/','*.tif'));
imnames_MeanFG = dir(fullfile(MeanFG_path,'/','*.tif'));
imnames_MaxF_SR = dir(fullfile(MaxF_SR_path,'/','*.tif'));
imnames_Intensive_frac = dir(fullfile(Intensive_frac_path,'/','*.tif')); 

%add by JQL
imnames_Manure = dir(fullfile(Manure_path,'/','*.tif')); 
imnames_Nfertilizer = dir(fullfile(Nfertilizer_path,'/','*.tif')); 
imnames_NDeposition = dir(fullfile(NDeposition_path,'/','*.tif')); 

imnames_MT = dir(fullfile(MT_path,'/','*.tif'));
imnames_MPre = dir(fullfile(MPre_path,'/','*.tif'));
imnames_FrostD = dir(fullfile(FrostD_path,'/','*.tif'));
imnames_WetD = dir(fullfile(WetD_path,'/','*.tif'));
imnames_LR = dir(fullfile(LR_path,'/','*.tif'));
imnames_MF = dir(fullfile(MF_path,'/','*.tif'));
imnames_MF_MSR = dir(fullfile(MF_MSR_path,'/','*.tif'));
imnames_Tem_max = dir(fullfile(Tem_max_path,'/','*.tif'));
imnames_Tem_min = dir(fullfile(Tem_min_path,'/','*.tif'));
imnames_Soil_Tem= dir(fullfile(Soil_Tem_path,'/','*.tif'));
imnames_Soil_Moisture = dir(fullfile(Soil_Moisture_path,'/','*.tif'));
imnames_Three_LAI = dir(fullfile(Three_LAI_path,'/','*.tif'));
imnames_ABD = dir(fullfile(ABD_path,'/','*.tif'));
imnames_EMT = dir(fullfile(EMT_path,'/','*.tif'));
temp_CO2 = xlsread(CO2_path);
%imnames_V_P = dir(fullfile(V_P_path,'/','*.tif'));
%imnames_Wind = dir(fullfile(Wind_path,'/','*.tif'));

%% vegetation type
info = geotiffinfo([IGBP_path,'/', imnames_IGBP(1).name]);
R=info.RefMatrix;
        
%% static(0.5)
temp_MAT = geotiffread(fullfile(MAT_path, imnames_MAT(1).name));
temp_MAPre = geotiffread(fullfile(MAPre_path, imnames_MAPre(1).name));
temp_MAPre(temp_MAPre>=999999)=NaN;
temp_MACWB = geotiffread(fullfile(MACWB_path, imnames_MACWB(1).name));
temp_MAPET = geotiffread(fullfile(MAPET_path, imnames_MAPET(1).name));
temp_MAPET(temp_MAPET>=999999)=NaN;
temp_MAIR = geotiffread(fullfile(MAIR_path, imnames_MAIR(1).name));
temp_MARH = geotiffread(fullfile(MARH_path, imnames_MARH(1).name));
temp_MARH(temp_MARH>=999999)=NaN;
temp_GSL = geotiffread(fullfile(GSL_path, imnames_GSL(1).name));
temp_IGBP = geotiffread(fullfile(IGBP_path, imnames_IGBP(1).name));

%add by JQL
temp_GSOC = geotiffread(fullfile(GSOC_path, imnames_GSOC(1).name));
temp_elevation = geotiffread(fullfile(elevation_path, imnames_elevation(1).name));
temp_slope = geotiffread(fullfile(slope_path, imnames_slope(1).name));
temp_tpi = geotiffread(fullfile(tpi_path, imnames_tpi(1).name));
temp_twi = geotiffread(fullfile(twi_path, imnames_twi(1).name));
temp_vbf = geotiffread(fullfile(vbf_path, imnames_vbf(1).name));

%% calculate
binCat = zeros(1, 46);
% for kk = 1982:2011
for kk = 2005:2008
    %year
    temp_MaxFY = geotiffread(fullfile(MaxFY_path, imnames_MaxFY(kk - 1981).name));
    temp_MinFY = geotiffread(fullfile(MinFY_path, imnames_MinFY(kk - 1981).name));
    temp_MA_F = geotiffread(fullfile(MA_F_path, imnames_MA_F(kk - 1981).name));
    temp_SumFG = geotiffread(fullfile(SumFG_path, imnames_SumFG(kk - 1981).name));
    temp_SF_SR = geotiffread(fullfile(SF_SR_path, imnames_SF_SR(kk - 1981).name));
    temp_MeanFG = geotiffread(fullfile(MeanFG_path, imnames_MeanFG(kk - 1981).name));
    temp_MaxF_SR = geotiffread(fullfile(MaxF_SR_path, imnames_MaxF_SR(kk - 1981).name));
    temp_Intensive_frac = geotiffread(fullfile(Intensive_frac_path, imnames_Intensive_frac(kk - 1981).name));

    %add by JQL
    temp_Manure = geotiffread(fullfile(Manure_path, imnames_Manure(kk - 1981).name));
    temp_Nfertilizer = geotiffread(fullfile(Nfertilizer_path, imnames_Nfertilizer(kk - 1981).name));
    temp_NDeposition = geotiffread(fullfile(NDeposition_path, imnames_NDeposition(kk - 1981).name));
    
    temp_CO2_month_data1 = temp_CO2(((kk-1982)*12+1):(kk-1981)*12, 1);
    
    for k = 1:12
        temp_CO2_month_data = temp_CO2_month_data1(k);
        %monthly but static in defferent year
        for m1 = 1:12
            if strfind(imnames_MMT(m1).name, sprintf('%02d.tif',k))
                temp_MMT = geotiffread(fullfile(MMT_path, imnames_MMT(m1).name));
                break
            else
                continue
            end
        end
        for m2 = 1:12
            if strfind(imnames_MMPre(m2).name, sprintf('%02d.tif',k))
                temp_MMPre = geotiffread(fullfile(MMPre_path, imnames_MMPre(m2).name));
                break
            else
                continue
            end
        end
        for m3 = 1:12
            if strfind(imnames_MMCWB(m3).name, sprintf('%02d.tif',k))
                temp_MMCWB = geotiffread(fullfile(MMCWB_path, imnames_MMCWB(m3).name));
                break
            else
                continue
            end
        end
        for m4 = 1:12
            if strfind(imnames_MMPET(m4).name, sprintf('%02d.tif',k))
                temp_MMPET = geotiffread(fullfile(MMPET_path, imnames_MMPET(m4).name));
                break
            else
                continue
            end
        end
        for m5 = 1:12
            if strfind(imnames_MMIR(m5).name, sprintf('%02d.tif',k))
                temp_MMIR = geotiffread(fullfile(MMIR_path, imnames_MMIR(m5).name));
                break
            else
                continue
            end
        end
%         for m6 = 1:12
%             if strfind(imnames_MMNWD(m6).name, sprintf('%02d.tif',k))
%                 temp_MMNWD = geotiffread(fullfile(MMNWD_path, imnames_MMNWD(m6).name));
%             else
%                 continue
%             end
%         end
        for m7 = 1:12
            if strfind(imnames_MMRH(m7).name, sprintf('%02d.tif',k))
                temp_MMRH = geotiffread(fullfile(MMRH_path, imnames_MMRH(m7).name));
                break
            else
                continue
            end
        end
        for m8 = 1:12
            if strfind(imnames_MMSR(m8).name, sprintf('%02d.tif',k))
                temp_MMSR = geotiffread(fullfile(MMSR_path, imnames_MMSR(m8).name));
                break
            else
                continue
            end
        end
        
        %month
        temp_MT = geotiffread(fullfile(MT_path, imnames_MT((kk - 1982) * 12 + k).name));
        temp_MPre = geotiffread(fullfile(MPre_path, imnames_MPre((kk - 1982) * 12 + k).name));
        temp_FrostD = geotiffread(fullfile(FrostD_path, imnames_FrostD((kk - 1982) * 12 + k).name));
        temp_WetD = geotiffread(fullfile(WetD_path, imnames_WetD((kk - 1982) * 12 + k).name));
        temp_MMLR = geotiffread(fullfile(LR_path, imnames_LR((kk - 1982) * 12 + k).name));
        temp_MF = geotiffread(fullfile(MF_path, imnames_MF((kk - 1982) * 12 + k).name));
        temp_MF_MSR = geotiffread(fullfile(MF_MSR_path, imnames_MF_MSR((kk - 1982) * 12 + k).name));        
        temp_Tem_max = geotiffread(fullfile(Tem_max_path, imnames_Tem_max((kk - 1982) * 12 + k).name));
        temp_Tem_min = geotiffread(fullfile(Tem_min_path, imnames_Tem_min((kk - 1982) * 12 + k).name));
        temp_Soil_Tem = geotiffread(fullfile(Soil_Tem_path, imnames_Soil_Tem((kk - 1982) * 12 + k).name));
        temp_Soil_Moisture = geotiffread(fullfile(Soil_Moisture_path, imnames_Soil_Moisture((kk - 1982) * 12 + k).name));
        temp_Three_LAI = geotiffread(fullfile(Three_LAI_path, imnames_Three_LAI((kk - 1982) * 12 + k).name));
        temp_ABD = geotiffread(fullfile(ABD_path, imnames_ABD((kk - 1982) * 12 + k).name));
        temp_EMT = geotiffread(fullfile(EMT_path, imnames_EMT((kk - 1982) * 12 + k).name));
        %temp_V_P = geotiffread(fullfile(V_P_path, imnames_V_P((kk - 1982) * 12 + k).name));
        %temp_Wind = geotiffread(fullfile(Wind_path, imnames_Wind((kk - 1982) * 12 + k).name));
        
        SplitX = NaN(1, 46);
        RegressX = NaN(1, 6);
        %16 is the number of trees,add mean layer=17
        data = NaN(1752,4320,17);
        for j = 1:size(data, 1)
            for jj = 1:size(data, 2)
                if temp_IGBP(j, jj) == 1
                    % split
                    SplitX(1,1) = temp_MAT(ceil(j/6), ceil(jj/6));
                    SplitX(1,2) = temp_MAPre(ceil(j/6), ceil(jj/6));
                    SplitX(1,3) = temp_MACWB(ceil(j/6), ceil(jj/6));
                    SplitX(1,4) = temp_MAPET(ceil(j/6), ceil(jj/6));
                    SplitX(1,5) = temp_MAIR(ceil(j/6), ceil(jj/6));
                    SplitX(1,6) = temp_MARH(ceil(j/6), ceil(jj/6));
                    SplitX(1,7) = temp_GSL(ceil(j/6), ceil(jj/6));
                    
                    SplitX(1,8) = temp_MMT(ceil(j/6), ceil(jj/6));
                    SplitX(1,9) = temp_MMPre(ceil(j/6), ceil(jj/6));
                    SplitX(1,10) = temp_MMCWB(ceil(j/6), ceil(jj/6));
                    SplitX(1,11) = temp_MMPET(ceil(j/6), ceil(jj/6));
                    SplitX(1,12) = temp_MMIR(ceil(j/6), ceil(jj/6));
                    SplitX(1,13) = temp_MMRH(ceil(j/6), ceil(jj/6));
                    
                    SplitX(1,14) = temp_MaxFY(j, jj);
                    SplitX(1,15) = temp_MinFY(j, jj); 
                    SplitX(1,16) = temp_MA_F(j, jj);
                    SplitX(1,17) = temp_SumFG(j, jj);
                    SplitX(1,18) = temp_SF_SR(j, jj);
                    SplitX(1,19) = temp_MeanFG(j, jj);
                    SplitX(1,20) = temp_MaxF_SR(j, jj);
                    SplitX(1,21) = temp_Intensive_frac(ceil(j/6), ceil(jj/6));
 
                    SplitX(1,22) = temp_MT(ceil(j/6), ceil(jj/6));
                    SplitX(1,23) = temp_MPre(ceil(j/6), ceil(jj/6));
                    SplitX(1,24) = temp_FrostD(ceil(j/6), ceil(jj/6));
                    SplitX(1,25) = temp_WetD(ceil(j/6), ceil(jj/6));
                    SplitX(1,26) = temp_MMSR(ceil(j/6), ceil(jj/6));
                    SplitX(1,27) = temp_MMLR(ceil(j/6), ceil(jj/6));
                    SplitX(1,28) = temp_MF(j, jj);
                    SplitX(1,29) = temp_MF_MSR(j, jj);
                    
                    SplitX(1,30) = temp_Tem_max(ceil(j/6), ceil(jj/6));
                    SplitX(1,31) = temp_Tem_min(ceil(j/6), ceil(jj/6));
                    SplitX(1,32) = temp_Soil_Tem(ceil(j/6), ceil(jj/6));
                    SplitX(1,33) = temp_Soil_Moisture(ceil(j/6), ceil(jj/6));
                    
                    SplitX(1,34) = temp_Three_LAI(j, jj);
                    SplitX(1,35) = temp_ABD(j, jj);
                    SplitX(1,36) = temp_EMT(j, jj);
                    SplitX(1,37) = temp_CO2_month_data;
                    
                    %add by JQL
                    SplitX(1,38) = temp_GSOC(j, jj);
                    SplitX(1,39) = temp_elevation(j, jj);
                    SplitX(1,40) = temp_slope(j, jj);
                    SplitX(1,41) = temp_tpi(j, jj);
                    SplitX(1,42) = temp_twi(j, jj);
                    SplitX(1,43) = temp_vbf(j, jj);
                    SplitX(1,44) = temp_Manure(ceil(j/6), ceil(jj/6));
                    SplitX(1,45) = temp_Nfertilizer(ceil(j/6), ceil(jj/6));
                    SplitX(1,46) = temp_NDeposition(ceil(j/6), ceil(jj/6));
                    

                    %regression
                    RegressX(1,1) = temp_MT(ceil(j/6), ceil(jj/6));
                    RegressX(1,2) = temp_MPre(ceil(j/6), ceil(jj/6));
                    RegressX(1,3) = temp_FrostD(ceil(j/6), ceil(jj/6));
                    RegressX(1,4) = temp_MMSR(ceil(j/6), ceil(jj/6));
                    RegressX(1,5) = temp_MMLR(ceil(j/6), ceil(jj/6));
                    RegressX(1,6) = temp_MF(j, jj);
                    %RegressX(1,3) = temp_MMIR(ceil(j/6), ceil(jj/6));
                    %RegressX(1,5) = temp_MF_MSR(j, jj);

                    %background set to NaN
                    SplitX(SplitX(:)>=1000000000 | SplitX(:)<=-9999) = NaN;
                    RegressX(RegressX(:)>=1000000000 | RegressX(:)<=-9999) = NaN;
                    %mte calculate
                    if nansum(isnan(SplitX)) == 0 && nansum(isnan(RegressX)) == 0
                        data1(1, :) = mtepredict(bestMTE, SplitX, RegressX, binCat);
                        data(j, jj, 1:16) = data1(1, :);
                        data(j, jj, 17) = nanmean(data1(1, :));
                        data1 = [];
                    else
                        data(j, jj,:) = NaN;
                    end
                else
                    data(j, jj,:) = NaN;
                end
            end
        end
        data(isnan(data)) = out_bv; 
        
        %% save
        for nlayer =1:17
            if nlayer == 17
                if k < 10
                    geotiffwrite([NEE_outpath,'/',num2str(kk), '0', num2str(k), out_prefix,'_MTEmean.tif'],data(:,:,17),R,'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);
                else
                    geotiffwrite([NEE_outpath,'/',num2str(kk),num2str(k), out_prefix,'_MTEmean.tif'],data(:,:,17),R,'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);
                end
            else
                if k < 10
                    geotiffwrite([NEE_outpath,'/',num2str(kk), '0', num2str(k), out_prefix,'_MT',num2str(nlayer),'.tif'],data(:,:,nlayer),R,'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);
                else
                    geotiffwrite([NEE_outpath,'/',num2str(kk),num2str(k), out_prefix,'_MT',num2str(nlayer),'.tif'],data(:,:,nlayer),R,'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);
                end
            end
        end
        data = [];
    end
    eatstr = ['Completed :  ',num2str((kk-1981)*100/(2011 - 1981)),'%'] ;
    disp(eatstr);
end
disp('Have fun, you have done ~ ~ ');