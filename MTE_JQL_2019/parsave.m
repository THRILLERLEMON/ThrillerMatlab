%保存parfor中的变量
function parsave(fname, Allnumber,AllRegressX,AllSplitX,AllY,binCat,i,indices,out_path,path,random_number,test,TestRegressX,TestSplitX,TestY,train,TrainRegressX,TrainSplitX,TrainY)
    save(fname, 'Allnumber','AllRegressX','AllSplitX','AllY','binCat','i','indices','out_path','path','random_number','test','TestRegressX','TestSplitX','TestY','train','TrainRegressX','TrainSplitX','TrainY')
end