%采用xlsread读取数据有不少缺点
% 如无法通过列标题获取数据
% 需要提前知道各列标题对应的数据在哪些列。
%
% 因此,不建议使用xlsread读取飞行模拟数据.
% 建议采用readtable读取cs,xlsx文件，以方便操作数据

filename = '51st Bisons vs CNF Rd 1__1HZ.csv'
[num,txt,raw] = xlsread(filename);
%M2 = csvread(filename);
%找到'Type'在raw的列索引
colIndex = find(strcmp(raw(1,:),'Type')) 
% strcmp(raw(:,colIndex),'Air+FixedWing') 
% 上一行得到'Type'为''Air+FixedWing'的0-1数组
% 可以作为行索引提取数据
% 示例:
t1 = raw(strcmp(raw(:,colIndex),'Air+FixedWing'),2:12);




