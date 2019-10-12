**目标**  
点尺度上找到解释变量与目标变量的关系，扩展到面尺度。  
步骤  
1、训练  
（1）AllDataTrainAMT.m  
使用所有数据训练模型树，调用mtbuild.m  
（2）mtbuild.m  
分裂变量、回归变量、目标变量、分裂变量类型（离散和连续）  
分裂变量：专门用来分裂成两部分的变量；  
回归变量：在叶子上进行多元线性回归的变量；  
最优准则：BIC。  
（3）交叉验证，5次交叉验证  
  
2、树扩展到森林  
森林，按照权重抽取一棵树。  
（1）随机剪枝  
（2）随机选一个分裂变量，随机分成两部分  
（3）再按照BIC准则再去分裂。  
训练好的树，放回森林，直到达到规定数目。  
  
3、选择ensemble  
取前n棵的平均值，找到最优的组合。  
  
4、升尺度  
面上的分裂变量和回归变量输入到模型中，得到面上的预测变量。  

**脚本介绍**  

***模型运行脚本***

脚本名称|作用|输入|直接输出|输出文件名称格式|备注
:-:|:-:|:-:|:-:|:-:|:-:
**AllDataTrainAMT**|构建一颗模型树|全部训练数据（xlsx）|训练脚本中的变量和模型树|Training_EnvVar.mat;MTAllTrain.mat|无
**CrossValind*N***|交叉验证|训练数据|5次交叉验证的模型树|验证的变量和验证生成的模型树|这个交叉验证是按照站点进行的分份
mtbuild|构建模型树|训练数据|模型树（mat）|MT*N*(N为第几次交叉验证)|无
**TestEveryMT**|验证模型树|模型树和测试训练数据|每一颗模型树的预测值和真值|xls文件|无
MTpredict|使用单个树计算预测值|模型树和解释变量数据|一颗模型树的预测值|matlab变量|无
**Parfor_Make5RandomCrossValind**|进行5份随机验证的准备|训练数据|5份随机验证使用的索引|mat文件|因为分份索引后续还要使用，并且要实现5个验证并行运行，所以先生成索引
**Parfor_Run5MT_*N***|运行5份随机验证的第*N*份|训练数据和分份索引|模型树|MT*N*(N为第几次交叉验证)|无
**TestEveryRandomMT**|验证模型树（随机验证生成）|模型树和测试训练数据|每一颗模型树的预测值和真值|xls文件RandomMTtestInfo_*N*|无
**MakeForest*N***|生成森林|根据模型树生成森林|森林|Forest*N*.mat|可能需要分部执行，之后使用Combine10Forest.m进行合并
mtEnsemble|生成森林和树组合|模型树和其他训练数据|森林（mat）和组合（mat）|Forest1.mat和MTE1.mat|无
**Combine10Forest**|合并多个森林|多个森林|一个合成之后的森林|Forest*.mat|无
**GetMTEPredictInfo**|在森林中寻找最优组合|森林和其他数据|返回MTE预测值和真值的对比矩阵|matlab变量|无
TF|在森林中提取一定个数的MTE|森林和想要的MTE中树的数量|返回MTE|matlab变量|无
mtepredict|根据模型树组合输出预测值|模型树组合和解释变量|返回预测值|matlab变量|无
test|输出MTE预测值和真值的R2|训练数据和MTE|返回MTE得出的均（中）值和真值回归的R2信息|matlab变量|无
**OutputBestMTE**|输出最优MTE|根据森林和最优组合树数|输出MTE|MTEbest.mat|无
**MT_Susceptibility_*RegressSplit*Var**|使用MT进行变量的敏感性实验|训练数据和模型树（MT）|输出个别解释变量变化后（增减20%）的预测值|excel文件|MTE_Susceptibility_*RegressSplit*Var类似
**VarSusceptibilityInfo_*SiteMonth***|对敏感性实验的数据进行处理|敏感性实验的输出数据|输出变量变化的均值和方差|excel文件|**SiteYear类似
**NEW_MTE_Susceptibility_*RegressSplit*Var**|对解释变量进行敏感性实验|训练数据和MYE|输出个变量变化（乱序）后的预测值和真值对比和敏感性|敏感性排序|无
**Calculate_NEE**|进行全球NEE的预测扩展|扩展数据和bestMTE|多年的月NEE数据|栅格文件（并输出MTE中每棵树的扩展结果）|最终使用的是结果中的MTEmean数据
**MTE_NEE_Uncertainty**|生成MTE_NEE数据的不确定性|扩展的NEE数据，MTE中每个MT的扩展栅格数据|每棵树的多年的标准差和变异系数|标准差和变异系数栅格|无


***数据分析脚本***

脚本名称|作用|输入|输出|备注
:-:|:-:|:-:|:-:|:-:
**GetAreaWeight**|生成全球的面积矩阵|栅格大小|面积矩阵（km^2）|没有使用，被直接使用areamat代替
**StaNEE_M2Y_Flux**|将月尺度的数据合成为年数据（加和）|月数据栅格|年数据栅格|无
**StaNEE_YearTotal**|使用年尺度的通量数据计算年尺度的草地NEE总量数据|年的通量数据，草地比例|年尺度的草地NEE栅格|Total=Flux✖栅格草地比例✖栅格面积
**StaNEE_Month2Season**|将月尺度数据合称为季度数据（加和）|月栅格数据|季度数据|345，678，91011，1212
**StaNEE_mean_years**|计算多年平均数据|多年数据栅格|多年平均数据|无
**StaNEE_Seasn_mean**|计算每个季度的多年平均值|多年多季度栅格数据|每个季度的多年平均栅格数据|无
**StaNEE_slp_P**|计算多年数据的趋势——slop|多年数据栅格|多年内的变化趋势slop|即y=kx+b的k
**StaNEE_STD_years**|计算多年数据的标准差|多年数据栅格|多年内数据的标准差|无
**StaNEE_std_hotspots**|输出NEE总量变化的热点区域（标准差较大的区域）|NEE年总量栅格数据|标准差百分位数区域|1（1-75）、75（75-90）、90（90-95）、95（95-100）
**StaNEE_std_hotspots_Sta**|对热点区域进行统计|热点区域数据、|多年平均NEE总量数据|统计为+，-的量，和净量
**StaNEE_Met_cor**|计算多变量和NEE的相关性|多年的NEE数据和多年的变量数据|相关系数（R）和显著相关（Rsig）|无
**StaNEE_drMet2v_NegPcor**|计算多变量和NEE的偏相关性|多年的NEE数据和多年的变量数据|相关系数（R）和显著相关（Rsig）|另外输出的min数据是表征到底哪个变量更加促进或者抑制NEE
**StaNEE_Pcor_withPRE_TEM_Pic**|NEE和多变量片相关出图|多变量和NEE的相关数据|哪个变量的相关系数更大|弃用
**StaNEE_psngNumSum**|统计出全时间段每个栅格上值为正负的次数|多年的NEE数据|为正为负的次数和加和数据|无
**StaNEE_psng30YAreaExt**|导出全时间段内一直为正一直为负的区域|全部年数据为正为负的次数|全为正和全为负的区域|无
**StaNEE_all30_SsSk_stat**|统计全时间段内（30年）各类栅格的面积、占比和NEE总量|多年平均NEE、草地比例数据、各类栅格数据|统计数据，面积、占比和NEE总量|统计一直为正/负；热点区域栅格
**StaNEE_IdePsNg**|识别栅格数据的正负|一个栅格数据|栅格正负的标记（1，-1，0）|无
**StaNEE_RelNEEPrebyStep**|按步取值探究NEE和降水的关系|多年平均降水和多年平均NEE|xls文件|降水10mm为Step，统计NEE的均值
**StaNEE_YttZones_VAR_mean**|统计某变量在全球和气候分区内的平均值|气候分区、多期的变量数据|统计结果|-99为时间（多期），9999指全球
**StaNEE_YttZonesMean**|统计NEE在全球和气候分区内平均值|气候分区、多期的NEE数据|统计结果|-99为时间（多期），9999指全球
**StaNEE_YttZonesSum**|统计NEE在全球和气候分区内总和值|气候分区、多期的NEE数据|统计结果|-99为时间（多期），9999指全球
**StaNEE_sum_FoldRas**|加和一个文件夹内的所有栅格数据|文件夹|加和数据|无
**StaNEE_Forst_M2Y_Ymean**|将Forst数据由月数据加和到年在求多年平均|Forst月数据|多年平均的Forst数据|无
**StaNEE_Frost_SR_space**|输出全球所有草地栅格对应的Forst和SR两个变量的值|变量的栅格和草地范围|两个变量的数据对|无
**StaNEE_Tem_Prp_space**|输出全球所有草地栅格对应的Temp和Prp两个变量的值|变量的栅格和草地范围|两个变量的数据对|无
**StaNEE_getVarSiteYear**|将变量的站点月数据加和成站点年数据|训练数据|变量的站点年数据|无
**StaNEE_flux_Zscore**|计算栅格的Zscore|多期栅格数据和基准数据的标准差和平均值|多期的Zscore|Zscore=（Raster-mean）std
**StaNEE_Classfiy8000ChangeKind**|分类出80s到00sNEE的变化类型|00s和80s的NEE平均值和00s-80s的栅格数据|变化类型|详见脚本
**StaNEE_CountPixelandPer**|统计栅格（唯一值）中的各个唯一值的个数和占所有栅格的比例|栅格|统计数据|无
**StaNEE_dif_2Raster**|输出两个栅格的差|两个栅格数据|栅格1-栅格2|无
**StaNEE_dif_MTE_Jung**|输出两个NEE产品（多年平均）的不同|两种数据|数据的差|栅格A-栅格B
**StaNEE_dif_IFOrNot**|输出有无（=0）草地管理NEE预测结果的区别|有无IF的NEE预测结果的多年平均|草地管理强度对NEE的影响|无

**运行日志**
*第一次运行-2019年9月21日*

1、运行平台
>Linux

2、执行内容
>使用所有的数据进行训练，生成一个模型树

3、使用脚本
>AllDataTrainAMT.m; mtbuild.m

4、运行目录
>/home/JiQiulei/MTE_JQL_2019

5、运行命令（pbs文件）
>#PBS -N matlab_job
 #PBS -l walltime=1000:00:00
 #PBS -l nodes=4:ppn=10
 #PBS -q cpu
 #PBS -o qjob_out.txt
 #PBS -e qjob_err.txt 
 cd /home/JiQiulei/MTE_JQL_2019
 /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop -r "AllDataTrainAMT" 1>RunADTMT.log 2>RunADTMT.err

6、运行结果
>在/home/JiQiulei/MTE_JQL_2019/MTE_RunRes路径中生成Training_EnvVar.mat和MTAllTrain.mat


*第二次运行-2019年9月23日*

1、运行平台
>Linux

2、执行内容
>进行交叉验证模型树的生成，5棵

3、使用脚本
>CrossValind1.m;CrossValind2.m;CrossValind3.m;CrossValind4.m;CrossValind5.m; 
 mtbuild.m

4、运行目录
>/home/JiQiulei/MTE_JQL_2019

5、运行命令
>nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < CrossValind1.m 1>RunCV1.log 2>RunCV1.err &
>nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < CrossValind2.m 1>RunCV2.log 2>RunCV2.err &
>nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < CrossValind3.m 1>RunCV3.log 2>RunCV3.err &
>nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < CrossValind4.m 1>RunCV4.log 2>RunCV4.err &
>nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < CrossValind5.m 1>RunCV5.log 2>RunCV5.err &

6、运行结果
>在/home/JiQiulei/MTE_JQL_2019/MTE_RunRes路径中生成
 CorssValindVar_1.mat;MTCorssValind1.mat;
 CorssValindVar_2.mat;MTCorssValind2.mat;
 CorssValindVar_3.mat;MTCorssValind3.mat;
 CorssValindVar_4.mat;MTCorssValind4.mat;
 CorssValindVar_5.mat;MTCorssValind5.mat;

*第三次运行-2019年9月24日*

1、运行平台
>Windows

2、执行内容
>验证交叉验证生成的5棵模型树

3、使用脚本
>TestEveryMT.m
 MTpredict.m
4、运行目录
>Windows

5、运行命令
>Windows Matlab

6、运行结果
>存储在运行结果文件夹

*第四次运行-2019年9月24日*

1、运行平台
>Linux

2、执行内容
>进行随机分成5份的交叉验证

3、使用脚本
>Parfor_Make5RandomCrossValind.m
 Parfor_Run5MT_1.m
 Parfor_Run5MT_2.m
 Parfor_Run5MT_3.m
 Parfor_Run5MT_4.m
 Parfor_Run5MT_5.m
 mtbuild.m
 
4、运行目录
>/home/JiQiulei/MTE_JQL_2019

5、运行命令
>nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < Parfor_Make5RandomCrossValind.m 1>RunRCVF.log 2>RunRCVF.err &
 nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < Parfor_Run5MT_1.m 1>RunRCV1.log 2>RunRCV1.err &
 nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < Parfor_Run5MT_2.m 1>RunRCV2.log 2>RunRCV2.err &
 nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < Parfor_Run5MT_3.m 1>RunRCV3.log 2>RunRCV3.err &
 nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < Parfor_Run5MT_4.m 1>RunRCV4.log 2>RunRCV4.err &
 nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < Parfor_Run5MT_5.m 1>RunRCV5.log 2>RunRCV5.err &

6、运行结果
>在/home/JiQiulei/MTE_JQL_2019/MTE_RunRes路径中生成

*第五次运行-2019年9月24日*

1、运行平台
>Windows

2、执行内容
>验证随机交叉验证生成的5棵模型树

3、使用脚本
>TestEveryRondomMT.m
 MTpredict.m
4、运行目录
>Windows

5、运行命令
>Windows Matlab

6、运行结果
>存储在运行结果文件夹

*第六次运行-2019年9月26日*

1、运行平台
>Linux

2、执行内容
>进行随机分成5份的交叉验证(无草地管理强度变量【Intensive_frac】)

3、使用脚本
>NoIF_Run5MT_1.m
 NoIF_Run5MT_2.m
 NoIF_Run5MT_3.m
 NoIF_Run5MT_4.m
 NoIF_Run5MT_5.m
 mtbuild.m
 
4、运行目录
>/home/JiQiulei/MTE_JQL_2019

5、运行命令
>nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < NoIF_Run5MT_1.m 1>RunNRCV1.log 2>RunNRCV1.err &
 nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < NoIF_Run5MT_2.m 1>RunNRCV2.log 2>RunNRCV2.err &
 nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < NoIF_Run5MT_3.m 1>RunNRCV3.log 2>RunNRCV3.err &
 nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < NoIF_Run5MT_4.m 1>RunNRCV4.log 2>RunNRCV4.err &
 nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < NoIF_Run5MT_5.m 1>RunNRCV5.log 2>RunNRCV5.err &

6、运行结果
>在/home/JiQiulei/MTE_JQL_2019/MTE_RunRes路径中生成

*第七次运行-2019年9月27日*

1、运行平台
>Windows

2、执行内容
>验证随机交叉验证生成的5棵模型树(无草地管理强度变量【Intensive_frac】参与训练)

3、使用脚本
>TestEveryRondomMT.m
 MTpredict.m
4、运行目录
>Windows

5、运行命令
>Windows Matlab

6、运行结果
>存储在运行结果文件夹

*第八次运行-2019年9月27日*

1、运行平台
>Windows

2、执行内容
>使用所有数据训练出来的数据进行变量敏感度测试

3、使用脚本
>Susceptibility_RegressSplitVar.m
 Susceptibility_SplitVarOnly.m
4、运行目录
>Windows

5、运行命令
>Windows Matlab

6、运行结果
>存储在运行结果文件夹

*第九次运行-2019年9月24日*

1、运行平台
>Linux

2、执行内容
>分10次，每次生成100棵树

3、使用脚本
>MakeForest1.m
 MakeForest2.m
 MakeForest3.m
 MakeForest4.m
 MakeForest5.m
 MakeForest6.m
 MakeForest7.m
 MakeForest8.m
 MakeForest9.m
 MakeForest10.m
 mtEnsemble.m（10个）
 
4、运行目录
>/home/JiQiulei/MTE_JQL_2019_IFregress

5、运行命令
>nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < MakeForest1.m 1>RunMF1.log 2>RunMF1.err &
 nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < MakeForest2.m 1>RunMF2.log 2>RunMF2.err &
 nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < MakeForest3.m 1>RunMF3.log 2>RunMF3.err &
 nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < MakeForest4.m 1>RunMF4.log 2>RunMF4.err &
 nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < MakeForest5.m 1>RunMF5.log 2>RunMF5.err &
 nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < MakeForest6.m 1>RunMF6.log 2>RunMF6.err &
 nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < MakeForest7.m 1>RunMF7.log 2>RunMF7.err &
 nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < MakeForest8.m 1>RunMF8.log 2>RunMF8.err &
 nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < MakeForest9.m 1>RunMF9.log 2>RunMF9.err &
 nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < MakeForest10.m 1>RunMF10.log 2>RunMF10.err &
 
6、运行结果
>在/home/JiQiulei/MTE_JQL_2019/MTE_RunRes路径中生成
 Forest1.mat
 Forest2.mat
 Forest3.mat
 Forest4.mat
 Forest5.mat
 Forest6.mat
 Forest7.mat
 Forest8.mat
 Forest9.mat
 Forest10.mat


*第十次运行-2019年9月27日*

1、运行平台
>Windows

2、执行内容
>将第八次运行生成的10个100棵树的Forest合并成1000棵树的森林

3、使用脚本
>Combine10Forest.m

4、运行目录
>Windows

5、运行命令
>Windows Matlab

6、运行结果
>存储在运行结果文件夹

*第十一次运行-2019年9月27日*

1、运行平台
>Linux

2、执行内容
>计算1000棵树的森林的组合的效果R2信息

3、使用脚本
>GetMTEPredictInfo.m

4、运行目录
>/home/JiQiulei/MTE_JQL_2019

5、运行命令
>nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < GetMTEPredictInfo.m 1>RunGMTEI.log 2>RunGMTEI.err &

6、运行结果
>在/home/JiQiulei/MTE_JQL_2019/MTE_RunRes路径中生成
 MTE_R2Info.mat
 MTEINFO_EnvVar.mat

*第十二次运行-2019年9月27日*

1、运行平台
>Windows

2、执行内容
>导出最优的MTE

3、使用脚本
>OutputBestMTE.m

4、运行目录
>Windows

5、运行命令
>Windows Matlab

6、运行结果
>存储在运行结果文件夹

*第十三次运行-2019年9月27日*

1、运行平台
>Windows

2、执行内容
>使用bestMTE进行变量敏感度测试

3、使用脚本
>MTE_Susceptibility_RegressSplitVar.m
 MTE_Susceptibility_SplitVarOnly.m
4、运行目录
>Windows

5、运行命令
>Windows Matlab

6、运行结果
>存储在运行结果文件夹


*扩展计算NEE-2019年10月5日*

脚本执行命令

Run Calculate_NEE
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < Calculate_NEE1.m 1>RunCN1.log 2>RunCN1.err &
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < Calculate_NEE2.m 1>RunCN2.log 2>RunCN2.err &
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < Calculate_NEE3.m 1>RunCN3.log 2>RunCN3.err &
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < Calculate_NEE4.m 1>RunCN4.log 2>RunCN4.err &
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < Calculate_NEE5.m 1>RunCN5.log 2>RunCN5.err &
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < Calculate_NEE6.m 1>RunCN6.log 2>RunCN6.err &

*NEE数据分析-2019年10月7日*

脚本执行命令

StaNEE_Month2YearStainZones
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < StaNEE_Month2YearStainZones.m 1>RunM2YS.log 2>RunM2YS.err &

StaNEE_Out_Month2YearsMean
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < StaNEE_Out_Month2YearsMean.m 1>RunOYSM.log 2>RunOYSM.err &

StaNEE_M2Y_Flux
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < StaNEE_M2Y_Flux.m 1>RunM2YF.log 2>RunM2YF.err &

StaNEE_YearTotal
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < StaNEE_YearTotal.m 1>RunM2YT.log 2>RunM2YT.err &

StaNEE_Month2Season
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < StaNEE_Month2Season.m 1>RunM2S.log 2>RunM2S.err &

MTE_NEE_Uncertainty
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < MTE_NEE_Uncertainty.m 1>RunMNU.log 2>RunMNU.err &

StaNEE_mean_years
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < StaNEE_mean_years.m 1>RunMY.log 2>RunMY.err &

StaNEE_YttZonesSum
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < StaNEE_YttZonesSum.m 1>RunYTZS.log 2>RunYTZS.err &

StaNEE_YttZonesMean
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < StaNEE_YttZonesMean.m 1>RunYTZM.log 2>RunYTZM.err &

StaNEE_Seasn_mean
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < StaNEE_Seasn_mean.m 1>RunSM.log 2>RunSM.err &

StaNEE_psngNumSum
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < StaNEE_psngNumSum.m 1>RunPNN.log 2>RunPNN.err &

StaNEE_std_hotspots
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < StaNEE_std_hotspots.m 1>RunHS.log 2>RunHS.err &

StaNEE_drMet2v_NegPcor
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < StaNEE_drMet2v_NegPcor.m 1>Run2NP.log 2>Run2NP.err &

StaNEE_dif_MTE_Jung
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < StaNEE_dif_MTE_Jung.m 1>RunDMJ.log 2>RunDMJ.err &

StaNEE_slp_P
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < StaNEE_slp_P.m 1>RunSLP.log 2>RunSLP.err &

StaNEE_all30_SsSk_stat
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < StaNEE_all30_SsSk_stat.m 1>Run30SSS.log 2>Run30SSS.err &

StaNEE_Met_cor
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < StaNEE_Met_cor.m 1>RunCPT.log 2>RunCPT.err &

StaNEE_flux_Zscore
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < StaNEE_flux_Zscore.m 1>RunZC.log 2>RunZC.err &

StaNEE_YttZones_VAR_mean
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < StaNEE_YttZones_VAR_mean.m 1>RunYZVM.log 2>RunYZVM.err &

StaNEE_dif_IFOrNot
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < StaNEE_dif_IFOrNot.m 1>RunIFON.log 2>RunIFON.err &

StaNEE_Forst_M2Y_Ymean
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < StaNEE_Forst_M2Y_Ymean.m 1>RunFM2YM.log 2>RunFM2YM.err &

StaNEE_sum_FoldRas
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < StaNEE_sum_FoldRas.m 1>RunSFR.log 2>RunSFR.err &

StaNEE_std_hotspots_Sta
nohup /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop < StaNEE_std_hotspots_Sta.m 1>RunHSS.log 2>RunHSS.err &