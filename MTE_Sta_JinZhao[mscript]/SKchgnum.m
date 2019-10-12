% Calculate the number of conversions between carbon source and carbon sink.
% And calculate the contributions of carbon source and carbon sink to changes in NEE over years.
% 2017.1.12
%% [s2k_num,k2s_num] = SKchgnum(nee)

function [s2k_num,k2s_num] = SKchgnum(nee)

Csk = sign(nee(:));

s2k_num = sum(diff(Csk)==-2);
k2s_num = sum(diff(Csk)==2);

return
end
