function Y = mtepredict(ensemble, SplitX, RegressX, binCat)

if nargin <1
    error('ensemble？~~~');
end

if nargin<3
    error('Input enough datas、、、');
end

if  (isempty(SplitX) || isempty(RegressX))
    error('predict data is empty or not enough.');
end

if  nargin < 6 || isempty(binCat)
    binCat = zeros(1, size(SplitX, 2));
end
[mSplitX, nSplitX] = size(SplitX);
[mRegressX, nRegressX] = size(RegressX);

if mSplitX ~= mRegressX
    error('samples are not equal...');
end

[mEnsemble, nEnsemble] = size(ensemble);
mn = mEnsemble * nEnsemble;
Y = NaN(mSplitX, mn);
for i = 1:mn
    for j = 1:mSplitX
        Y(j, i) = predict(ensemble{i}, SplitX(j, :), RegressX(j, :), binCat);
    end
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
