function cellwt = GetAreaWeight(deg)
rows=180/deg;
cols=360/deg;
halfSize = deg/2;
tmp = ones(rows,1,'single');
R = makerefmat(-180+halfSize, 90-halfSize, deg, -deg);
EP = almanac('earth','wgs84','kilometers');
[~,wt] = areamat((tmp>-1),R,EP);
cellwt = repmat(wt,[1 cols]);
end
