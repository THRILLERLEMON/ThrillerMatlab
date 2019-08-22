%判断年份是否为闰年，分别输出总日数、闰年数及平年数
clear;close all;clc;
starty=1982;
stopy=2015;
ynum=stopy-starty+1;
a=zeros(ynum,2);
a(:,1)=(starty:stopy);
run=0;
ping=0;
for year=1:ynum
    if mod(a(year,1),400)==0||(mod(a(year,1),4)==0 && mod(a(year,1),100)~=0)
        run=run+1;
        a(year,2)=366;
    else
        ping=ping+1;
        a(year,2)=365;
    end
end
days=sum(a(:,2),1);
disp(['自',num2str(a(1,1)),'年到',num2str(a(ynum,1)),'年共',num2str(ynum),'年,共',num2str(days),'天']);
disp(['闰年共有',num2str(run),'年']);
disp(['平年共有',num2str(ping),'年']);