**目标**
点尺度上找到解释变量与目标变量的关系，扩展到面尺度。
步骤
1、训练
（1）mainProgramme.m
随机分成5份，4份训练，1份验证，调用mtbuild.m
>没问题，执行Main_Programme.m 修改路径即可

（2）mtbuild.m
分裂变量、回归变量、目标变量、分裂变量类型（离散和连续）
分裂变量：专门用来分裂成两部分的变量；
回归变量：在叶子上进行多元线性回归的变量；
最优准则：BIC。
（3）完成训练，5棵树中取最优的一棵树。
>运行MTpredict 计算每棵树的R2，选择最优

2、树扩展到森林
森林，按照权重抽取一棵树。
（1）随机剪枝
（2）随机选一个分裂变量，随机分成两部分
（3）再按照BIC准则再去分裂。
训练好的树，放回森林，直到达到规定数目。
>有方法脚本，需要在matlab中手动运行或者写新脚本

3、选择ensemble
取前n棵的平均值，找到最优的组合。
>有方法脚本，需要在matlab中手动运行或者写新脚本

4、升尺度
面上的分裂变量和回归变量输入到模型中，得到面上的预测变量。

**脚本介绍**
脚本名称|作用|输入|直接输出|输出文件名称格式
-|:-:|:-:|:-:|-
**Main_Programme**|构建一颗模型树|训练数据（xlsx）|每次的交叉验证的变量|Test_*N*(N为第几次交叉验证)
mtbuild|构建模型树|拆分后的训练数据|一次验证的模型树（mat）|MT*N*(N为第几次交叉验证)
**TestEveryMT**|使用单个树计算预测值|模型树和训练数据|每一颗模型树的预测值|数据和R2
MTpredict|使用单个树计算预测值|模型树和训练数据|一颗模型树的预测值|matlab变量
**MakeForestGetMTE**|生成森林并生成模型树组合信息|模型树和训练数据|森林和组合信息|Forest1.mat和MTE_R2Info.mat
mtEnsemble|生成森林和树组合|模型树和其他训练数据|森林（mat）和组合（mat）|Forest1.mat和MTE1.mat
Found_Best_Ensemble_From_Forest|在森林中寻找最优组合|森林和其他数据|返回MTE预测值和真值的对比矩阵|matlab变量
TF|在森林中提取一定个数的MTE|森林和想要的MTE中树的数量|返回MTE|matlab变量
mtepredict|根据模型树组合输出预测值|模型树组合和解释变量|返回预测值|matlab变量
**OutputBestMTE**|输出最优MTE|根据森林和最优组合树数|输出MTE|MTEbest.mat

**运行日志**
*第一次运行-2019年9月19日*
1、运行平台
>Linux

2、执行内容
>进行5次交叉验证生成对应的5个模型树

3、使用脚本
>Main_Programme.m; mtbuild.m

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
 /opt/matlab/MATLAB/R2014b/bin/matlab -nodisplay -nodesktop -r "Main_Programme" 1>matlabRun.log 2>matlabRun.err

6、运行结果

