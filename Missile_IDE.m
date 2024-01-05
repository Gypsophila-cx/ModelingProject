%% 判断一场战斗中每颗导弹的发射机和目标机
%莫名其妙的慢
function [LauR_Id,TarR_Id,LauB_Id,TarB_Id,tableR,tableB]=Missile_IDE(str)
%具体的运行地址（的前半部分）——根据自己的文件夹调整
loc = "D:\和学校有关的，所有\数据科学中的数学方法\三、仿真数据挖掘\附件1-1Hz\";
%分别写出这场战斗中红蓝两方导弹的运行地址，备用...还有中立导弹
path_red = strcat(loc,str,'\Weapon\Red');
path_blue = strcat(loc,str,'\Weapon\Blue');
path_violet = strcat(loc,str,'\Weapon\Violet');%中立导弹要做吗？不做吗？
pathRA = strcat(loc,str,'\Air\Red');
pathBA = strcat(loc,str,'\Air\Blue');
%这场战斗的起始时间，还要把整个数据找出来，好麻烦。
%以及总战斗秒数，即最大的时刻减去初始的
Dtp = readtable(strcat(loc,str,'.csv'));
T=Dtp.UnixTime;
t0=min(T); tN=max(T)-t0+1;

%% 测试测试
tableR = table();
tableB = table();

%% 先处理红方
cd(path_red);
%获取这个文件夹下的所有文件（表格），并排除那些谜之隐藏文件
fileList = dir(path_red);
fileList = fileList(~startsWith({fileList.name}, '.'));
%获取这些表格的名称，用字符串格式
misNames = {fileList.name};
misNames = string(misNames);
%建立每颗导弹的发射机序列
for i=1:length(misNames)
    weapon_temp = readtable(misNames(i));
    LauR_Id(i) = Launcher_IDE(weapon_temp,pathRA);
    tableR = Target_IDE(weapon_temp,pathBA,tableR);
    cd(path_red);%好像环境会变，总之怪怪的，手动调回来吧
end
tableR.Properties.VariableNames = {'tar_id', 'Mdist','tink','t1','t2','Fdist','tar_id2','Ldist'};
tableR.Mdist = str2double(tableR.Mdist);
tableR.Ldist = str2double(tableR.Ldist);
tableR.Fdist = str2double(tableR.Fdist);
tableR.tink = str2double(tableR.tink);
tableR.t1 = str2double(tableR.t1);
tableR.t2 = str2double(tableR.t2);
%把击中时间算成战斗时长比例
tableR.tink = floor(100*(tableR.tink-t0)/tN);
%为了美观调整为列向量
LauR_Id = LauR_Id';
TarR_Id = tableR.tar_id;
%以前后两秒来算吧，虽然也很随意
distDiff = tableR.Mdist-2*tableR.Fdist;
for i=1:length(misNames)
    flag = 0;%因为Target_IDE中用两种不同判定法，当Mdist4与LineD不同时需要进一步判定
    %如果两者几乎同时消失且距离误差在一定范围内，则视作“击中”
    if tableR.t1(i)+tableR.t2(i)<5 && distDiff(i)<100
        TarR_Id(i) = strcat(TarR_Id(i)," DE");  flag = 1;
    end
    %如果飞机在最近点后迅速消失且距离误差较小，则视作“击伤”
    if tableR.t2(i)<10 && distDiff(i)<0
        TarR_Id(i) = strcat(TarR_Id(i)," DA-P");    flag = 1;
    end
    %如果飞机消失时刻恰为两者最近时刻，则视作“失去目标（被其他导弹击中）”
    if tableR.t1(i)>0 && tableR.t2(i)==0
        TarR_Id(i) = strcat(TarR_Id(i)," LOST");    flag = 1;
    end
    %如果Mdist4中没有给目标机特定标记且与LineD不同，则进行判定
    if flag == 0 && tableR.tar_id(i) ~= tableR.tar_id2(i) && tableR.Mdist(i)>tableR.Ldist(i)
        TarR_Id(i) = tableR.tar_id2(i);
    end
end

%% 再处理蓝方
cd(path_blue);
%获取这个文件夹下的所有文件（表格），并排除那些谜之隐藏文件
fileList = dir(path_blue);
fileList = fileList(~startsWith({fileList.name}, '.'));
%获取这些表格的名称，用字符串格式
misNames = {fileList.name};
misNames = string(misNames);
%建立每颗导弹的发射机序列
for i=1:length(misNames)
    weapon_temp = readtable(misNames(i));
    LauB_Id(i) = Launcher_IDE(weapon_temp,pathBA);
    tableB = Target_IDE(weapon_temp,pathRA,tableB);
    cd(path_blue);%好像环境会变，总之怪怪的，手动调回来吧
end
tableB.Properties.VariableNames = {'tar_id', 'Mdist','tink','t1','t2','Fdist','tar_id2','Ldist'};
tableB.Mdist = str2double(tableB.Mdist);
tableB.Ldist = str2double(tableB.Ldist);
tableB.Fdist = str2double(tableB.Fdist);
tableB.tink = str2double(tableB.tink);
tableB.t1 = str2double(tableB.t1);
tableB.t2 = str2double(tableB.t2);
tableB.tink = floor(100*(tableB.tink-t0)/tN);
%为了美观调整为列向量
LauB_Id = LauB_Id';
TarB_Id = tableB.tar_id;
distDiff = tableB.Mdist-2*tableB.Fdist;
for i=1:length(misNames)
    flag = 0;
    %如果两者几乎同时消失且距离误差在一定范围内，则视作“击中”
    if tableB.t1(i)+tableB.t2(i)<5 && distDiff(i)<100
        TarB_Id(i) = strcat(TarB_Id(i)," DE");  flag = 1;
    end
    %如果飞机在最近点后迅速消失且距离误差较小，则视作“击伤”
    if tableB.t2(i)<10 && distDiff(i)<0
        TarB_Id(i) = strcat(TarB_Id(i)," DA-P");    flag = 1;
    end
    %如果飞机消失时刻恰为两者最近时刻，则视作“失去目标（被其他导弹击中）”
    if tableB.t1(i)>0 && tableB.t2(i)==0
        TarB_Id(i) = strcat(TarB_Id(i)," LOST");    flag = 1;
    end
    %如果Mdist4中没有给目标机特定标记且与LineD不同，则进行判定
    if flag == 0 && tableB.tar_id(i) ~= tableB.tar_id2(i) && tableB.Mdist(i)>tableB.Ldist(i)
        TarB_Id(i) = tableB.tar_id2(i);
    end
end

