%% 未击中的情况，是无击中、击伤后的第二个判断步骤
%最重要的是判断到底是未击中还是无目标
%采用导弹行进轨迹方向上有没有敌机的判断标准
%时间不能太短，但是距离呢？
%分成m段
function [tar_id2, Ldist] = LineD(mdat,airName,m)
M = inf*zeros(length(airName),2);   M(:,1) = 1:length(airName);
misT = [mdat.UnixTime,mdat.Longitude,mdat.Latitude,mdat.Altitude,mdat.TAS];
tar_id2 = "NO LINE";    Ldist = inf;
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
    %在两者的重合时间中取m点，如果段数m相比tb-ta+1太多，直接不考虑是不是目标机
    DivP = floor(linspace(ta,tb,m));
    if length(DivP) > tb-ta+1 
        continue
    end
    %这m个时间点上飞机和导弹的位置
    ind_a = zeros(m,1);     ind_m = zeros(m,1);
    for j = 1:m
        ind_a(j) = find(airT(:,1)==DivP(j));
        ind_m(j) = find(misT(:,1)==DivP(j));
    end
    airDP = airT(ind_a,2:4);
    misDP = misT(ind_m,2:4);
    %视作m-1段折线，计算每一段折线（直线化）彼此之间的距离
    diseq = zeros(m-1,1);
    for j = 1:m-1
        diseq(j) = Dist_2line(airDP(j,:),airDP(j+1,:),misDP(j,:),misDP(j+1,:));
    end
    M(i,2) = mean(diseq);
end

s = find(M(:,2)==min(M(:,2)));
if ~isempty(s)
    Ldist = M(s,2);
    tar_id2 = airName(s);
    tar_id2 = erase(tar_id2,".csv");
end