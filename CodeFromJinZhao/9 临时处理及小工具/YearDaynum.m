%判断年份是否为闰年，输出总日数并在其后添加对应年
clear;
starty=1982;
stopy=2012;
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
%在多年日序列每天的日数前添加对应年份
daynum=zeros(days,2);
daynum(:,2)=(1:days);
for dnum=starty:stopy
    if dnum==starty
        daynum(1:a(1,2),1)=dnum;
    else
        daynum(sum(a(1:dnum-starty,2))+1:sum(a(1:dnum-starty+1,2)),1)=dnum;
    end
end
% xlswrite('G:\VIC_mat\强迫数据VIC_forcing\year_day.xls',a,'sheet2');
% disp('finish');
dlmwrite('/public/home/liangwei/Download/aaaaa/year_days.dat',a,'\t');