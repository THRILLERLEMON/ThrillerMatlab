% 0.5度全球草地分区统计各气象要素平均值
clear;close all;clc

%%  Input

ras_pt = '/home/JiQiulei/MTE_JQL_2019/NewAddData/Manure_Application1982_2011';  % 待分区统计数据

gclm_fl = '/home/JiQiulei/MTE_JQL_2019/World_Koppen_Map_0.5_reclas5_grass.tif';  % 0.5度草地气候分区数据

% stnm = 'GM';  % 输出结果sheet名
% outxls = 'F:\SCI投稿\Nature\NEE\Manuscript\JGR_Biogeoscience\First_revised\Data\GM_1982-2011_NBV.xlsx';  % 输出xls文件


%%  Operate

Ginfo = geotiffinfo(gclm_fl);
gclm = double(imread(gclm_fl));
gclm(gclm==gclm(1,1))=nan;

afs = dir([ras_pt,'/*.tif']);
result = nan(length(afs),5);
globalres=nan(length(afs),1);
for fl = 1:length(afs)
    vars = double(imread([ras_pt,'/',afs(fl).name]));
    vars(vars==-9999)=nan;
    vars=vars(1:size(gclm,1),:);%为了避免统计分区的行号小于待统计指标的行号（即使2者的行列数相同），比如草地管理分区中并没有南极，虽如果不加此句判断，统计的数据比如NEE可能会将南极地区也统计进去
    glotmp=vars(~isnan(gclm));
    globalres(fl,1)=nanmean(glotmp(:));
    for clm = 1:5
        tmp = vars(gclm==clm); %判断条件  gclm==clm 位置向量 返回1和0的逻辑矩阵
        result(fl,clm)=nanmean(tmp(:));
    end
end

dlmwrite(['/home/JiQiulei/MTE_JQL_2019/NEE_Sta','/',num2str(1982),'-',num2str(2011),'Manure_Application_zone_MEAN.txt'],...
    [[-99,1,2,3,4,5,9999];[(1982:2011)',result,globalres]],'delimiter',' ')
% warning off MATLAB:xlswrite:AddSheet;
% xlswrite(outxls,{afs.name}',stnm,'a2')
% xlswrite(outxls,(1:5),stnm,'b1')
% xlswrite(outxls,result,stnm,'b2')

disp('Finish!')
