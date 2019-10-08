% 0.5��ȫ��ݵط���ͳ�Ƹ�����Ҫ��ƽ��ֵ
clear;close all;clc

%%  Input

ras_pt = '/home/JiQiulei/MTE_JQL_2019/NewAddData/Manure_Application1982_2011';  % ������ͳ������

gclm_fl = '/home/JiQiulei/MTE_JQL_2019/World_Koppen_Map_0.5_reclas5_grass.tif';  % 0.5�Ȳݵ������������

% stnm = 'GM';  % ������sheet��
% outxls = 'F:\SCIͶ��\Nature\NEE\Manuscript\JGR_Biogeoscience\First_revised\Data\GM_1982-2011_NBV.xlsx';  % ���xls�ļ�


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
    vars=vars(1:size(gclm,1),:);%Ϊ�˱���ͳ�Ʒ������к�С�ڴ�ͳ��ָ����кţ���ʹ2�ߵ���������ͬ��������ݵع�������в�û���ϼ�����������Ӵ˾��жϣ�ͳ�Ƶ����ݱ���NEE���ܻὫ�ϼ�����Ҳͳ�ƽ�ȥ
    glotmp=vars(~isnan(gclm));
    globalres(fl,1)=nanmean(glotmp(:));
    for clm = 1:5
        tmp = vars(gclm==clm); %�ж�����  gclm==clm λ������ ����1��0���߼�����
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
