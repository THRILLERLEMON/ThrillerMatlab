% Windows 10 1903
% 2019.10.09
clear;close all;clc;tic

%%  input

RasPt = 'E:\OFFICE\MTE_NEE_DATA\RunResult\Sta_NEE\80s00s\Classfiy80s00sChangeKind.tif';
outpt = 'C:\Users\thril\Desktop';

Ras = double(imread(RasPt));
bv=-128;
Ras(Ras==bv) = nan;
Ras2 = Ras(:);
Ras2(isnan(Ras2)) = [];
uqRas = unique(Ras2(:));

allCount=sum(~isnan(Ras2));
countRes=[];
for k = 1:length(uqRas)
    thisCount=sum(Ras2==uqRas(k));
    countRes=[countRes;thisCount];
end

output=[uqRas,countRes,countRes./allCount];

xlswrite([outpt,'\CountPixcel_Classfiy80s00sChangeKind.xls'], output);


disp('ok!')




