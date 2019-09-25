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
脚本名称|作用|输入|直接输出|输出文件名称格式
:-:|:-:|:-:|:-:|:-:
**AllDataTrainAMT**|构建一颗模型树|全部训练数据（xlsx）|训练脚本中的变量和模型树|Training_EnvVar.mat;MTAllTrain.mat
**CrossValind**|交叉验证|训练数据|5次交叉验证的模型树|验证的变量和验证生成的模型树
mtbuild|构建模型树|训练数据|模型树（mat）|MT*N*(N为第几次交叉验证)
**TestEveryMT**|验证模型树|模型树和测试训练数据|每一颗模型树的预测值和真值|TestEveryMT_*N*.mat(N为第几次交叉验证)
MTpredict|使用单个树计算预测值|模型树和解释变量数据|一颗模型树的预测值|matlab变量
**MakeForestGetMTE**|生成森林并生成模型树组合信息|模型树和训练数据|森林和组合信息|Forest1.mat和MTE_R2Info.mat
mtEnsemble|生成森林和树组合|模型树和其他训练数据|森林（mat）和组合（mat）|Forest1.mat和MTE1.mat
Found_Best_Ensemble_From_Forest|在森林中寻找最优组合|森林和其他数据|返回MTE预测值和真值的对比矩阵|matlab变量
TF|在森林中提取一定个数的MTE|森林和想要的MTE中树的数量|返回MTE|matlab变量
mtepredict|根据模型树组合输出预测值|模型树组合和解释变量|返回预测值|matlab变量
**OutputBestMTE**|输出最优MTE|根据森林和最优组合树数|输出MTE|MTEbest.mat

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

*第六次运行-2019年9月24日*
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
>/home/JiQiulei/MTE_JQL_2019

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


