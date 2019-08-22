%pettitt��ģ�£���p<=0.05����Ϊ������ͻ�����ͳ���������������ġ�[t,p]=pt_test(y,start,alpha)
%1.�������ݣ�
%   y����������ݣ�
%   start����ʼ��ݣ�
%   alpha��������ˮƽ������0.05������95%����ˮƽ��
%   figtitle��ͼ��
%2.�������
%   t��ͻ����ݣ�
%   p��������ˮƽ

%%

function [t, p, sk] = pt_test_print(y, start, alpha, figtitle)
% start=1961;
len = length(y);
sk = nan(len - 1, 1);
for i = 1:len - 1
    r_k = 0;
    for j = 1:i
        for k = i + 1:len
            r_k = r_k + sign(y(k) -y(j));
        end
    end
    sk(i) = r_k;
end

sk = abs(sk);
sk_ture = max(sk);
t = find(sk==sk_ture) - 1 + start;
p = 2 * exp(-6 * (sk_ture) ^ 2 / (len ^ 2 + len ^ 3));
[~, ~, muci, ~] = normfit(sk, alpha);
%fig

f_down = floor(min(sk)) - 2;
if f_down >= floor(muci(2)) - 50
    f_down = floor(muci(2)) - 100;
end
f_up = ceil(max(sk)) + 2;
if f_up <= ceil(muci(1)) + 50
    f_up = ceil(muci(1)) + 100;
end

pic = figure;
plot(start:start + len - 2, sk, 'r-', 'linewidth', 3)
hold on
plot(start:start + len - 2, muci(1) * ones(len - 1, 1), 'k-.', 'linewidth', 2)
plot(start:start + len - 2, muci(2) * ones(len - 1, 1), 'k-.', 'linewidth', 2)
axis([start, start + length(sk) - 1, f_down, f_up]);
ylabel('ͳ����K_T', 'FontName', 'TimesNewRoman', 'Fontsize', 24, 'fontweight', 'bold');
title(figtitle, 'FontName', 'TimesNewRoman', 'Fontsize', 30, 'fontweight', 'bold')
set(gca, 'FontName', 'TimesNewRoman', 'Fontsize', 20, 'fontweight', 'bold')

legend('S_k', [num2str((1 - alpha) * 100), '%��������']);

% % print
% set(gca, 'position', [.1, .1, .85, .8])
% print(pic, '-r96', '-djpeg', outfig)

end