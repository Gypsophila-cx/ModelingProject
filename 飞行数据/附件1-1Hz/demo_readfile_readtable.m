function demo_exp
% csvread(filename)
% [NUM,TXT,RAW]=xlsread(filename) TXT,RAW为cell数组
% T =readtable(filename)  T为table型数组.
global data
%addpath('D:\temp\W15A\实验项目4--综合实验项目')

filename = '51st Bisons vs CNF Rd 1__1HZ.csv'

data = readflyingdata(filename);

r1 = getunique(data,'Type')
TYPEPLANE = 'Air+FixedWing';
TYPEBOMB  = 'Weapon+Missile';

d1 = getdata(data,'Type',TYPEPLANE);
planeids = table2cell(unique(d1(:,'Id'))) % 转为cell型数组,似乎更好操作一些

d2 = unique(getdata(data,'Type',TYPEBOMB));
bombids = table2cell(unique(d2(:,'Id'))) % 转为cell型数组

data_plane = cell(1,length(planeids))
for i=1:length(planeids)
    data_plane{i} = getdata(data,'Type',TYPEPLANE,...
        'Id',planeids{i});
end

data_bomb = cell(1,length(bombids))
for i=1:length(bombids)
    data_bomb{i} = getdata(data,'Type',TYPEBOMB,...
        'Id',bombids{i});
end
%绘制某个飞机的数据
d = data_plane{1};
basedraw(d)

function basedraw(d)
subplot(2,2,1)  % 飞行高度
x = table2array(d(:,'UnixTime'));x = x - min(x);
y = table2array(d(:,'Altitude')); % 飞行高度数据
plot(x,y,'.'),ylabel('飞行高度')   
subplot(2,2,2)
x = table2array(d(:,'UnixTime'));x = x - min(x);
y = table2array(d(:,'TAS'));% 真空速
plot(x,y,'.'),ylabel('真空速')
subplot(2,2,3)
x = table2array(d(:,'UnixTime'));x = x - min(x);
y = table2array(d(:,'Pitch')); % 俯仰角
plot(x,y,'.'),ylabel('俯仰角') % 
subplot(2,2,4)     
x = table2array(d(:,'UnixTime'));x = x - min(x);
y = table2array(d(:,'Roll'));% 滚转角
plot(x,y,'.'),ylabel('滚转角') %

function data = readflyingdata(filename)
% 读取飞行实验数据
data = readtable(filename);


function r = getdata(data,field1,value1,field2,value2)
% field1,field2 均为存储字符串数组的字段名称
% 如'Id','Type'字段.
t1 = strcmp(table2cell(data(:,field1)),value1);
if nargin ==5
    t2 = strcmp(table2cell(data(:,field2)),value2);
    r = data(t1 & t2,:);%获取满足条件的数据
else
    r = data(t1,:);
end

function r = getunique(data,fieldname)
%获取指定列的不重复的元素
% data 原始数据.table类型
%fieldname 字段名,char数组
r = unique(data(:,fieldname));


