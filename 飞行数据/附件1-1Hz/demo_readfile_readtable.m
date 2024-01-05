function demo_exp
% csvread(filename)
% [NUM,TXT,RAW]=xlsread(filename) TXT,RAWΪcell����
% T =readtable(filename)  TΪtable������.
global data
%addpath('D:\temp\W15A\ʵ����Ŀ4--�ۺ�ʵ����Ŀ')

filename = '51st Bisons vs CNF Rd 1__1HZ.csv'

data = readflyingdata(filename);

r1 = getunique(data,'Type')
TYPEPLANE = 'Air+FixedWing';
TYPEBOMB  = 'Weapon+Missile';

d1 = getdata(data,'Type',TYPEPLANE);
planeids = table2cell(unique(d1(:,'Id'))) % תΪcell������,�ƺ����ò���һЩ

d2 = unique(getdata(data,'Type',TYPEBOMB));
bombids = table2cell(unique(d2(:,'Id'))) % תΪcell������

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
%����ĳ���ɻ�������
d = data_plane{1};
basedraw(d)

function basedraw(d)
subplot(2,2,1)  % ���и߶�
x = table2array(d(:,'UnixTime'));x = x - min(x);
y = table2array(d(:,'Altitude')); % ���и߶�����
plot(x,y,'.'),ylabel('���и߶�')   
subplot(2,2,2)
x = table2array(d(:,'UnixTime'));x = x - min(x);
y = table2array(d(:,'TAS'));% �����
plot(x,y,'.'),ylabel('�����')
subplot(2,2,3)
x = table2array(d(:,'UnixTime'));x = x - min(x);
y = table2array(d(:,'Pitch')); % ������
plot(x,y,'.'),ylabel('������') % 
subplot(2,2,4)     
x = table2array(d(:,'UnixTime'));x = x - min(x);
y = table2array(d(:,'Roll'));% ��ת��
plot(x,y,'.'),ylabel('��ת��') %

function data = readflyingdata(filename)
% ��ȡ����ʵ������
data = readtable(filename);


function r = getdata(data,field1,value1,field2,value2)
% field1,field2 ��Ϊ�洢�ַ���������ֶ�����
% ��'Id','Type'�ֶ�.
t1 = strcmp(table2cell(data(:,field1)),value1);
if nargin ==5
    t2 = strcmp(table2cell(data(:,field2)),value2);
    r = data(t1 & t2,:);%��ȡ��������������
else
    r = data(t1,:);
end

function r = getunique(data,fieldname)
%��ȡָ���еĲ��ظ���Ԫ��
% data ԭʼ����.table����
%fieldname �ֶ���,char����
r = unique(data(:,fieldname));


