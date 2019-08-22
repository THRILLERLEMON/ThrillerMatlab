%MK���Ƽ����Լ�������,[z,slope,p,Uf,Ub]=MKts(y,alpha,start)��yΪ�����һ�����ݣ�10�����������Ϻã�alphaΪ����ˮƽ����0.05��startΪ��ʼ��ݣ���1956
function [z, slope, p, Uf, Ub] = MKts_print(y, alpha, start, outfig, figtitle)

n = length(y);

%% Sen+Mann-Kendall���Ʒ���(��������10����)

s = 0;  %����ͳ����S����
for i = 1:n - 1
    s = s + sum(y(i+1:n) > y(i)) - sum(y(i + 1:n) < y(i));
end
if n > 10
    vs = n * (n - 1) * (2 * n + 5) / 18;    %ͳ��������
    z = (s - sign(s)) * abs(sign(s)) / sqrt(vs);    %ͳ������׼��̬�ֲ�Zֵ����
    nslp = n * (n - 1) / 2; %Sen���ƶȼ���
    slp = nan(nslp, 1);
    counter = 1;
    for i = 1:n - 1
        for j = i + 1:n
            slp(counter) = (y(j) - y(i)) / (j - i);
            counter = counter + 1;
        end
    end
    slope = median(slp);
elseif n <= 10
    z = s;
    slope = nan;
end
p = norminv(1 - alpha / 2);

%% ͻ�����

Uf = nan(n, 1);
Uf(1) = 0;  %Uf��Ub����
Ub = nan(n, 1);
Ub(1) = 0;

yb = flipud(y(:));
for i = 2:n
    s_uf = 0;
    s_ub = 0;
    for j = 2:i
        s_uf = s_uf + sum(y(j) > y(1:j - 1));
        s_ub = s_ub + sum(yb(j) > yb(1:j - 1));
    end
    Uf(i) = (s_uf - i * (i - 1) / 4) / sqrt(i * (i - 1) * (2 * i + 5) / 72);
    Ub(i) = (s_ub - i * (i - 1) / 4) / sqrt(i * (i - 1) * (2 * i + 5) / 72);
end
Ub = -flipud(Ub);

%% ��ͼ

pic = figure;
plot(start:start + n - 1, Uf, 'b-', 'linewidth', 3)  % Uf
hold on
f_down = floor(min([Uf; Ub])) - 1;
if f_down >= floor(-p) - 0.5
    f_down = floor(-p) - 1.5;
end
f_up = ceil(max([Uf; Ub])) + 2;
if f_up <= ceil(p) + 0.5
    f_up = ceil(p) + 1.5;
end
plot(start:start + n - 1, Ub, 'r-', 'linewidth', 2)  % Ub
axis([start, start + n - 1, f_down, f_up]);

% sig
plot(start:start + n - 1, p * ones(n, 1), 'k:', 'linewidth', 2)
plot(start:start + n - 1, -p * ones(n, 1), 'k:', 'linewidth', 2)
title(figtitle)
legend('UF_k', 'UB_k', ['P<', num2str(alpha)]);
ylabel('statistic', 'FontName', 'TimesNewRoman', 'Fontsize', 14, 'fontweight', 'bold');
set(gca, 'xtick', start:2:start + n - 1, 'fontsize', 12);
set(gca, 'ytick', f_down:0.5:f_up);
xtl = get(gca, 'XTickLabel');
xt = get(gca, 'XTick');
yt = get(gca, 'YTick');
ytextp = (yt(1) - 2 * (yt(2) - yt(1))) * ones(1, length(xt));
text(xt, ytextp, xtl, 'HorizontalAlignment', 'right', 'rotation', -90, 'fontsize', 12);
text(xt(end) + 1.5, p, num2str(p), 'fontsize', 12);
text(xt(end) + 1.5, -p, num2str(-p), 'fontsize', 12);
set(gca, 'xticklabel', '');

% print
set(gca, 'position', [.1, .1, .8, .8])
print(pic, '-r96', '-djpeg', outfig);

end
