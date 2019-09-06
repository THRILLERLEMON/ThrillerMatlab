function R2 = Found_Best_Ensemble_From_Forest(SplitX, RegressX,Y,SplitTestX,RegressTestX,TestY,AllSplitX, AllRegressX,AllY,binCat,forest)
    R2 = NaN(4, 91);
    for i = 14:100
        R2(i, i-9) = i - 9;
        ensemble = TF(forest, i);
        PredictTrainY = mtepredict(ensemble, SplitX, RegressX, binCat);
        PredictTestY = mtepredict(ensemble, SplitTestX,RegressTestX,binCat);
        PredictAllY = mtepredict(ensemble, AllSplitX, AllRegressX, binCat);
        [~,stats1] = test(PredictTrainY, Y, 2);
        R2(2, i-9) = stats1(1);
        [~, stats2] = test(PredictTestY, TestY, 2);
        R2(3, i-9) = stats2(1);
        [~,stats3] = test(PredictAllY, AllY, 2);
        R2(4, i-9) = stats3(1);
        
        eststr = ['Completed :', num2str(i*100/91), '%'];
        disp(eststr);
    end