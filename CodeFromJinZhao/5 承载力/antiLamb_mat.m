% convert projection coordinates to geographic coordinates
% Lambert equal area azimuthal projection with center
% 2018.3.13
function [lat,lon] = antiLamb_mat(Y,X,erthRd,lat_cntr,lon_cntr)
%% [lat,lon] = antiLamb(Y,X,erthRd,lat_cntr,lon_cntr)
XX = X/erthRd;
YY = Y/erthRd;

RAO = sqrt(XX.^2+YY.^2);
C1 = 2*asind(RAO/2);  % D
lat = asind(cosd(C1)*sind(lat_cntr)+YY.*sind(C1)*cosd(lat_cntr)./RAO);
lon = lon_cntr+atand(XX.*sind(C1)./(RAO*cosd(lat_cntr).*cosd(C1)-YY*sind(lat_cntr).*sind(C1))); 
end