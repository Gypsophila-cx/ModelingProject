%% 击中击伤，也许都可以用“最近距离四元组”来判断
%最近距离四元组=[最近飞机，最近距离，最近时刻到导弹消失时间，最近时刻到最近飞机消失时间]
%最近距离小，时间1，时间2小=击中
%最近距离小，时间1，时间2中=击伤
%输入导弹的资料和敌对飞机名称（注意直接在对应地址运行该程序）
%想了想还是加上移动速度吧
function [tar_id, Mdist, tink, t1, t2, Fdist] = Mdist4(mdat,airName)
%一架飞机一架飞机地找，M矩阵的每一行代表每架飞机的最近点数据
M = inf*zeros(length(airName),6);   M(:,1) = 1:length(airName);
misT = [mdat.UnixTime,mdat.Longitude,mdat.Latitude,mdat.Altitude,mdat.TAS];
for i = 1:length(airName)
    air_temp = readtable(airName(i));
    airT = [air_temp.UnixTime,air_temp.Longitude,air_temp.Latitude,air_temp.Altitude,air_temp.TAS];
    %查找导弹与飞机重合的时间
    ta = max(airT(1,1),misT(1,1)); taa = find(airT(:,1)==ta); tam = find(misT(:,1)==ta);
    tb = min(airT(end,1),misT(end,1));
    %如果没有交集，就略去这架飞机
    if ta > tb
        continue
    end
    diseq = zeros(tb-ta+1,1);
    for j = 1:tb-ta+1
        diseq(j) = Dist_lao2eu(airT(taa+j-1,2:4),misT(tam+j-1,2:4));
    end
    M(i,2) = min(diseq);
    t0 = find(diseq==min(diseq))+ta-1;
    M(i,3) = t0;
    M(i,4) = misT(end,1)-t0;
    M(i,5) = airT(end,1)-t0;
    M(i,6) = airT(t0-ta+1,5)+misT(t0-ta+1,5);
end
s = find(M(:,2)==min(M(:,2)));
%在第一场战斗中有导弹完全不和敌机重合（莫名其妙）
Mdist = M(s,2);
Fdist = M(s,6);
tink = M(s,3);
t1 = M(s,4);
t2 = M(s,5);
tar_id = airName(s);
tar_id = erase(tar_id,".csv");


%% 如果M矩阵中实际只有一行数据=只有一架飞机，说明实际上没有目标（巡航机）
if sum(isnan(M(:,2)))==length(airName)-1
    tar_id = "NO TAR";
end