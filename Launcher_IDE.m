%% 判断一颗导弹的发射机，标准为导弹出现时刻距离最近的飞机
%分别输入导弹的数据表格，和对应阵营的飞机的文件夹地址
function Id = Launcher_IDE(mdat,pathA)
%这颗导弹的经纬度、海拔时间序列
A = table2array([mdat(:,2),mdat(:,4),mdat(:,5),mdat(:,6)]);
Lid = A(1,:);%A的第一行，就是发射时刻和初始的位置

cd(pathA);
%获取这个文件夹下的所有文件（表格），并排除那些谜之隐藏文件
%由于上一步把BAS也放进了文件夹里，弄得整体多了一个文件，很尴尬
fileList = dir(pathA);
fileList = fileList(~startsWith({fileList.name}, '.'));
%获取这些表格的名称，用字符串格式
fileNames = {fileList.name};
fileNames = string(fileNames);
%不要读BAS
ts = fileNames=="BAS_RED.csv" | fileNames=="BAS_BLUE.csv";
fileNames(ts)=[];


%% 逐架飞机检查事发时刻的位置
diseq=zeros(length(fileNames),1);
for i = 1:length(fileNames)
    air_temp = readtable(fileNames(i));
    air_temp = table2array([air_temp(:,2),air_temp(:,4),air_temp(:,5),air_temp(:,6)]);
    %如果这枚导弹发射前这架飞机还没起飞或者已经坠落，那么和它的距离设置为inf
    if Lid(1) < air_temp(1,1) || Lid(1) > air_temp(end,1)
        diseq(i) = inf;
    else
        ind = find(air_temp(:,1)==Lid(1));
        %以防万一，如果有两架飞机最近，就暂停
        if length(ind)>1
            disp('ind wrong')
            pause;
        end
        %飞机快速机动可能会有误差，在前后三秒中取最小值，但是可能ind恰好在开头结尾
        MAdist=Dist_lao2eu(air_temp(ind,2:4),Lid(2:4))*ones(3,1);
        if air_temp(1,1) < air_temp(ind,1)
            MAdist(2) = Dist_lao2eu(air_temp(ind-1,2:4),Lid(2:4));
        end
        if air_temp(end,1) > air_temp(ind,1)
            MAdist(3) = Dist_lao2eu(air_temp(ind+1,2:4),Lid(2:4));
        end
        diseq(i) = min(MAdist);
    end
end
k = find(diseq==min(diseq));
Id = fileNames(k(1));
Id = erase(Id,".csv");

%如果发射时刻最近的飞机与导弹距离过远，就拎出来看看
%观察得，存在不是由飞机发射的导弹，如第一场战斗蓝方的7D0A
%判断不是由飞机发射导弹，应当考虑为发射时刻的短时间内导弹与飞机的路程赶不上
air_lau = readtable(fileNames(k));
air_lauT = table2array([air_lau(:,2),air_lau(:,4),air_lau(:,5),air_lau(:,6)]);
ind = find(air_lauT(:,1)==Lid(1));
if min(diseq)>mdat.RelativeTime(1)*mdat.TAS(1)+air_lau.TAS(ind)
    Id = "MAY NOT AIR";
end