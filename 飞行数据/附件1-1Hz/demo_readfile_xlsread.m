%����xlsread��ȡ�����в���ȱ��
% ���޷�ͨ���б����ȡ����
% ��Ҫ��ǰ֪�����б����Ӧ����������Щ�С�
%
% ���,������ʹ��xlsread��ȡ����ģ������.
% �������readtable��ȡcs,xlsx�ļ����Է����������

filename = '51st Bisons vs CNF Rd 1__1HZ.csv'
[num,txt,raw] = xlsread(filename);
%M2 = csvread(filename);
%�ҵ�'Type'��raw��������
colIndex = find(strcmp(raw(1,:),'Type')) 
% strcmp(raw(:,colIndex),'Air+FixedWing') 
% ��һ�еõ�'Type'Ϊ''Air+FixedWing'��0-1����
% ������Ϊ��������ȡ����
% ʾ��:
t1 = raw(strcmp(raw(:,colIndex),'Air+FixedWing'),2:12);




