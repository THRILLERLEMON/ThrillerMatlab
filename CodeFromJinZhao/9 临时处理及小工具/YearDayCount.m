%�ж�����Ƿ�Ϊ���꣬�ֱ��������������������ƽ����
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
disp(['��',num2str(a(1,1)),'�굽',num2str(a(ynum,1)),'�깲',num2str(ynum),'��,��',num2str(days),'��']);
disp(['���깲��',num2str(run),'��']);
disp(['ƽ�깲��',num2str(ping),'��']);