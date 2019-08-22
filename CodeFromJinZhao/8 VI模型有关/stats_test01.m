% 统计
% 2016.9.15 中秋节
clear;clc
tmp = [];
Xs = (1999:2015)';

%%  regress
% 矩阵 逐列
% slope p mean std
bv = -9999;
n = size(tmp,2);
rst = nan(5,n);
for ic = 1:n
    Y = tmp(:,ic);
    Y(Y==bv) = [];
    [b,~,~,~,stats]=regress(Y,[(1:length(Y))',ones(length(Y),1)]);
    rst(1,ic)=b(1); % k
    rst(2,ic)=b(2); % b
    rst(3,ic)=stats(3); % P
    rst(4,ic)=mean(Y); % mean
    rst(5,ic)=std(Y); % std
end

%%  regress X
% 矩阵 逐列
% slope p mean std
bv = -9999;
n = size(tmp,2);
rst = nan(5,n);
Xst_ed = nan(2,n);
for ic = 1:n
    Y = tmp(:,ic);
    Y(Y==bv) = [];
    [b,~,~,~,stats]=regress(Y,[Xs,ones(length(Y),1)]);
    rst(1,ic)=b(1); % k
    rst(2,ic)=b(2); % b
    rst(3,ic)=stats(3); % P
    rst(4,ic)=mean(Y); % mean
    rst(5,ic)=std(Y); % std
    
    Xst_ed(:,ic) = [Xs(1)*b(1)+b(2);Xs(end)*b(1)+b(2)];
end

