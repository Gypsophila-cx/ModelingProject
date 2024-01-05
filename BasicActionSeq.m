%% 用符号化的方法，以1秒为间隔输出一场战斗中各飞机的动作序列
function BasicActionSeq(str)
%具体的运行地址（的前半部分）——根据自己的文件夹调整
loc = "D:\和学校有关的，所有\数据科学中的数学方法\三、仿真数据挖掘\附件1-1Hz\";
%分别写出这场战斗中红蓝两方的运行地址，备用
path_red = strcat(loc,str,'\Air\Red');
path_blue = strcat(loc,str,'\Air\Blue');
%这场战斗的起始时间，还要把整个数据找出来，好麻烦。
%以及总战斗秒数，即最大的时刻减去初始的
Dtp = readtable(strcat(loc,str,'.csv'));
T=Dtp.UnixTime;
t0=min(T); tN=max(T)-t0+1;

%% 先处理红方
cd(path_red);
%获取这个文件夹下的所有文件（表格），并排除那些谜之隐藏文件
fileList = dir(path_red);
fileList = fileList(~startsWith({fileList.name}, '.'));
%获取这些表格的名称，用字符串格式
fileNames = {fileList.name};
fileNames = string(fileNames);
%建立红方的BAS列表
BAS_RED = zeros(tN,length(fileNames)+1);
BAS_RED(:,1) = 1:tN;
colname = ["UnixTime", erase(fileNames,".csv")];
BAS_RED = array2table(BAS_RED, 'VariableNames', colname);
%最后的总体修饰，把所有的0替换为“静止”
Sre = repmat("静止",tN,1);
%用BAS_Gener输出一张只有红方的基本动作序列表
for i=1:length(fileNames)
    air_temp = readtable(fileNames(i));
    [bas,t(i)]=BAS_Gener(air_temp);
    t(i)=t(i)-t0+1;
    Sre_temp = Sre; Sre_temp(t(i):t(i)+length(bas)-1)=bas;
    BAS_RED.(colname(i+1))=num2str(BAS_RED.(colname(i+1)));
    BAS_RED.(colname(i+1))=Sre_temp;
end

%% 再处理蓝方，这一步完全是copy上面
cd(path_blue);
%获取这个文件夹下的所有文件（表格），并排除那些谜之隐藏文件
fileList = dir(path_blue);
fileList = fileList(~startsWith({fileList.name}, '.'));
%获取这些表格的名称，用字符串格式
fileNames = {fileList.name};
fileNames = string(fileNames);
%建立红方的BAS列表
BAS_BLUE = zeros(tN,length(fileNames)+1);
BAS_BLUE(:,1) = 1:tN;
colname = ["UnixTime", erase(fileNames,".csv")];
BAS_BLUE = array2table(BAS_BLUE, 'VariableNames', colname);
%最后的总体修饰，把所有的0替换为“静止”
Sre = repmat("静止",tN,1);
%用BAS_Gener输出一张只有蓝方的基本动作序列表
for i=1:length(fileNames)
    air_temp = readtable(fileNames(i));
    [bas,t(i)]=BAS_Gener(air_temp);
    t(i)=t(i)-t0+1;
    Sre_temp = Sre; Sre_temp(t(i):t(i)+length(bas)-1)=bas;
    BAS_BLUE.(colname(i+1))=num2str(BAS_BLUE.(colname(i+1)));
    BAS_BLUE.(colname(i+1))=Sre_temp;
end

%% 最后把这两张表分别输出到各自的文件夹里
cd(path_red);
writetable(BAS_RED,'BAS_RED.csv','Encoding','GBK');%中文乱码调整
cd(path_blue);
writetable(BAS_BLUE,'BAS_BLUE.csv','Encoding','GBK');
