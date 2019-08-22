% RMSE及NES简易计算
clear;clc
wb=[];vi=[];

%%  part 1 行变量

rmse = nan(size(wb, 1), 1);
for st = 1:size(wb, 1)
    wb1 = wb(st, :);
    vi1 = vi(st, :);
    rmse(st) = sqrt(sum((wb1 - vi1).^2) / size(wb, 2));
end

%% part 2 单列

rmse = sqrt(sum((wb - vi).^2) / length(wb));
rmm=rmse*100/mean(wb);
bis = mean(vi-wb);
bis2 = mean(vi-wb)*100/mean(wb);
nse = 1-(sum((vi-wb).^2)/sum((wb-mean(wb)).^2));

%%  part 3 列变量

rmse = nan(1, size(wb, 2));
for st = 1:size(wb, 2)
    wb1 = wb(:, st);
    vi1 = vi(:, st);
    rmse(st) = sqrt(sum((wb1 - vi1).^2) / size(wb, 1));
end

%%  Bias

vibias = mean(vi)-mean(wb);
vibiasp = vibias*100/mean(wb);


