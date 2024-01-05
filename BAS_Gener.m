%% 用张北的程序串一串，给单个飞机的数据制作动作序列
%输入的dat是一张表格，输出一条列向量bas和起始时间
function [bas,t0]=BAS_Gener(dat)
A=table2array([dat(:,8),dat(:,7),dat(:,6),dat(:,2)]);
%读入数据，第一列是偏航角（以正北方向为0）
%第二列是俯仰角（水平方向为0）
%第三列是滚转角，描绘飞机是否在滚转
%第四列是时间，为后面分析做准备

t0=A(1,4);%这架飞机的出现时间
%符号化处理
flag=signifying(A);
%符号化动作
bas_S=judgeaction1(flag);
%文字化动作
bas=judgeaction2(bas_S);