function [b, stats] = test( Ytest, Y, number)
%YtestΪԤ�����
%YΪ�۲��
%ȡnumber = 1ʱ��Ytestȡ��ֵ��number=2ʱ��ȡYtestΪ��ֵ��Ĭ��Ϊ��ֵ
if  nargin <2
    error(' Datas are not enough~ ~ ~ ');
end

if nargin<3
    number = 2;
end
switch number
    case 1
        for i = 1:size(Ytest, 1)
            Y1(i, 1) = median(Ytest(i,:));
        end
    case 2
        for i = 1:size(Ytest, 1)
            Y1(i, 1) = mean(Ytest(i,:))-0.5;
        end
    case 3
        for i = 1:size(Ytest, 1)
            Y1(i, 1) = mode(Ytest(i, :));
        end
    case 4
        for i = 1:size(Ytest, 1)
            Y1(i, 1) = (mode(Ytest(i, :)) + mean(Ytest(i, :)) + median(Ytest(i,:)))/3;
        end
    case 5
        for i = 1:size(Ytest, 1)
            Y1(i, 1) = mode(Ytest(i, :)) - mean(Ytest(i, :)) + median(Ytest(i,:));
        end
    case 6
        for i = 1:size(Ytest, 1)
            Y1(i, 1) = mode(Ytest(i, :)) - (mean(Ytest(i, :)) - median(Ytest(i,:)))*0.7;
        end
    case 7
        for i = 1:size(Ytest, 1)
            Y1(i, 1) =3* mean(Ytest(i, :)) - median(Ytest(i,:))- mode(Ytest(i, :))-17;
        end
    case 8
end
% for j = 1:size(Ytest, 1)
%     if Y1(j) < 0
%         Y1(j) = NaN;
%         Ytest(j) = NaN;
%     end
% end
% for k = 1:size(Ytest, 1)
%     if Ytest(k) < 0
%         Y1(k) = NaN;
%         Ytest(k) = NaN;
%     end
% end
% plot(Y1, Y, '.');
% hold on
% t = polyfit(Y1, Y, 2); %��������κ��������ϵ��
% f = polyval(t, Y);      %�����������ߵ�������
% plot(Y1, Y,'k*',Y,f,'r--','linewidth',0.1);
Y2 = [ones(length(Y1),1),Y1];
[b, ~, ~, ~, stats] = regress(Y, Y2, 0.01);
% plot(Y1, Y, 'rx');
% hold on
% xxx = -250:1:100;
% YY = xxx.*b(2) + b(1);
% plot( xxx,YY,'--b','linewidth',1.5);
% % regstats(Y1, Y,'linear');
% % scatter(Y1, Y, 5, 'r');
% hold on
% x = -250:0.01:100;
% xx = -250:0.01:100;
% plot(xx,x,'-k','linewidth',1.5);
% hold on 
% axis([-200 100 -200 100]);

end

