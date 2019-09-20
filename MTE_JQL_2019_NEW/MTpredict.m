function PredictY = MTpredict(node, SplitX, RegressX, binCat)
mSplitX = size(SplitX,1 );
PredictY = NaN(mSplitX, 1);
for i = 1: mSplitX
    PredictY(i) = predict(node, SplitX(i,:), RegressX(i,:), binCat);
    eatstr = ['Complated :',num2str(i*100/mSplitX),'%'];
    disp(eatstr);
end
end

%计算一棵树、一个样本的预测值
function Yq = predict(node, SplitX, RegressX, binCat)
if strcmp(node.type, 'INTERIOR')
    if binCat(node.splitAttribute) == 1
        if ~isnan(SplitX(1, node.splitAttribute))
			if ismember(SplitX(1, node.splitAttribute), node.leftInd)
				Yq = predict(node.left, SplitX, RegressX, binCat);
			else
				Yq = predict(node.right, SplitX, RegressX, binCat);
			end
		else
			Yq = NaN;
        end
        
    else
        if binCat(node.splitAttribute) == 0
            if ~isnan(SplitX(1, node.splitAttribute))
                if SplitX(1, node.splitAttribute) < node.splitLocation
					Yq = predict(node.left, SplitX, RegressX, binCat);
				else
					Yq = predict(node.right, SplitX, RegressX, binCat);
                end
            else
				Yq = NaN;
            end
            
        end
    end
else
    if strcmp(node.type, 'LEAF')
        if ~isempty(node.model.attrInd)
			if ~any(isnan(RegressX(1, node.model.attrInd)))
				Yq = RegressX(1, node.model.attrInd) * node.model.coefs(2:end) + node.model.coefs(1);
			end 
        end
    end
end
end