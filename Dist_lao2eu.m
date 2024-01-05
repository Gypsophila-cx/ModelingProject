%% 用两个经纬度海拔坐标点算出这两个点之间的欧式距离
function d=Dist_lao2eu(X,Y)
% 地球平均半径（单位：米）
ER = 6371000;

% 将经纬度转换为弧度
lon1 = deg2rad(X(:,1));
lat1 = deg2rad(X(:,2));
lon2 = deg2rad(Y(:,1));
lat2 = deg2rad(Y(:,2));
Rx = ER+X(:,3);
Ry = ER+Y(:,3);
x = [Rx*cos(lat1)*cos(lon1),Rx*cos(lat1)*sin(lon1),Rx*sin(lat1)];
y = [Ry*cos(lat2)*cos(lon2),Ry*cos(lat2)*sin(lon2),Ry*sin(lat2)];

% 计算两个点之间的距离
d = sqrt((x-y)*(x-y)');
end