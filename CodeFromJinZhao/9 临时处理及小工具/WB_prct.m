% 计算数值对应百分位
% 多列数据，每一列为一个流域逐年结果

%%  percentile

clear;close all;clc
olddata=[];

prgap = 5;

%%

pgap = 1/(prgap/100);
[m,n] = size(olddata);

rst = nan(pgap,n);
for ic = 1:n
    tmp = sort(olddata(:,ic),'descend');
    prt = (1:m)'/m;
    for ix = 1:pgap
        id1 = find(prt<=ix/pgap,1,'last');
        id2 = find(prt>=ix/pgap,1,'first');
        if id1==id2
            yix = tmp(id1);
        else
            x2 = prt(id2);
            x1 = prt(id1);
            y2 = tmp(id2);
            y1 = tmp(id1);
            ygap = y2-y1;
            xgap = x2-x1;
            
            yix = y1+(ix/pgap-x1)*((y2-y1)/(x2-x1));
        end
        rst(ix,ic) = yix;
    end
end

newdata = sort(olddata,'descend');

disp('Finish!')
