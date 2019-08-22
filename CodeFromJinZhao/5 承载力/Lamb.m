% Lambert equal area azimuthal projection with center(105,35)
% 2017.8.4
function [Y,X] = Lamb(lat,long)
Radius = 6370997;
PI = pi/180;

lat1 = 35*PI;
lon1 = 105*PI;
lat5 = PI*lat;
lon5 = PI*long;

ak = 1+sin(lat1)*sin(lat5)+cos(lat1)*cos(lat5).*cos(lon5-lon1);
ak = (2./ak).^0.5;
X = Radius*ak.*cos(lat5).*sin(lon5-lon1);
Y = Radius*ak.*(cos(lat1)*sin(lat5)-sin(lat1)*cos(lat5).*cos(lon5-lon1));

end