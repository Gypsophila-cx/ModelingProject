%% 判断一颗导弹的发射机，基本标准为导弹飞行过程中离切线最近的飞机，具体标准比较复杂
%有好几种判断方式，好好好麻烦
%分别输入导弹的数据表格，和对应阵营的飞机的文件夹地址
function TM = Target_IDE(mdat,pathA,TM0)
%在对方阵营中寻找目标机
cd(pathA);
%获取这个文件夹下的所有飞机文件（表格），并排除那些谜之隐藏文件
%由于上一步把BAS也放进了文件夹里，弄得整体多了一个文件，很尴尬
fileList = dir(pathA);
fileList = fileList(~startsWith({fileList.name}, '.'));
%获取这些表格的名称，用字符串格式
fileNames = {fileList.name};
fileNames = string(fileNames);
%不要读BAS
ts = fileNames=="BAS_RED.csv" | fileNames=="BAS_BLUE.csv";
fileNames(ts)=[];


%% 逐架飞机检查
%目标机可以分为6类 
%1.无目标：敌机只剩巡航机或其他战术目的，丢弃导弹的情形
%2.或许无目标：受损战斗机坠机前胡乱发射导弹
%3.击中：直接击中目标，导弹和敌机几乎同时同地点消失
%4.击伤：擦过目标，导弹没有消失，敌机受损，一段时间后消失
%5.未击中：有目标机但被甩掉
%6.未击中：多枚导弹攻击同一目标机，其中一枚击中后，其他导弹失去目标

%% 测试新程序，用最近点判断法——Mdist4来测试
[tar_id, Mdist, tink, t1, t2, Fdist] = Mdist4(mdat,fileNames);

%% 第二判别点——LineD的最近
m = 5;%手动指定
[tar_id2, Ldist] = LineD(mdat,fileNames,m);

%% 把所有东西放一起
row = array2table([tar_id, Mdist, tink, t1, t2, Fdist, tar_id2, Ldist]);
TM = [TM0;row];