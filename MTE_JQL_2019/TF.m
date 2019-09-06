%提取集合
function ensemble = TF(forest, number)
%forest为训练出来的森林
%number为想提取的ensemble中树的个数
[m, n] = size(forest);
bic = NaN(m, n);

%提取bic
for i = 1:m*n
    bic(i) = forest{i}.bic;
end
sortbic = sort(bic(:));
nn = 1;
ensemble = cell(1, number);
for j = 1:number
    mm = find(bic(:) == sortbic(nn));
    if length(mm) > 1
        ensemble{j} = forest{mm(1)};
        nn = nn + length(mm);
    else
        ensemble{j} = forest{mm};
        nn = nn + 1;
    end
end
end