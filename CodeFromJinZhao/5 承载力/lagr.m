%% Lagrange interpolation
%% 2018.3.26
function Z = lagr(xo,yo,T)
xo = xo(:);
yo = yo(:);
Z = 0;
n = length(yo);
idx = find(xo<T,1,'last');
K = max([1,idx-4]);
M = min([idx+3,n]);

for idy = K:M
    S = 1;
    for j1 = K:M
        if j1~=idy
            S = S*(T-xo(j1))/(xo(idy)-xo(j1));
        end
    end
    Z = Z+S*yo(idy);
end

end