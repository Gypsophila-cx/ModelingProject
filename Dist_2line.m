%% 用两条直线上各自两个点的经纬度海拔坐标点算出这两条直线之间的欧式距离
function d=Dist_2line(X1,X2,Y1,Y2)
% 地球平均半径（单位：米）
ER = 6371000;

% 将经纬度转换为弧度
lonX1 = deg2rad(X1(:,1));   lonX2 = deg2rad(X2(:,1));
latX1 = deg2rad(X1(:,2));   latX2 = deg2rad(X2(:,2));
lonY1 = deg2rad(Y1(:,1));   lonY2 = deg2rad(Y2(:,1));
latY1 = deg2rad(Y1(:,2));   latY2 = deg2rad(Y2(:,2));
RX1 = ER+X1(:,3);   RX2 = ER+X2(:,3);
RY1 = ER+Y1(:,3);   RY2 = ER+Y2(:,3);
%转换为直角坐标
x1 = [RX1*cos(latX1)*cos(lonX1),RX1*cos(latX1)*sin(lonX1),RX1*sin(latX1)];
x2 = [RX2*cos(latX2)*cos(lonX2),RX2*cos(latX2)*sin(lonX2),RX1*sin(latX2)];
y1 = [RY1*cos(latY1)*cos(lonY1),RY1*cos(latY1)*sin(lonY1),RY1*sin(latY1)];
y2 = [RY2*cos(latY2)*cos(lonY2),RY2*cos(latY2)*sin(lonY2),RY1*sin(latY2)];

% 计算两个点之间的距离
Vx = x2-x1; Vy = y2-y1;
M = [x1-y1;Vx;Vy];
d = abs(det(M))/norm(cross(Vx,Vy));
end