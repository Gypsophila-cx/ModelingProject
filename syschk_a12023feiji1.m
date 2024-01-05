function a12023feiji1
% Team 16. 找实体关系的程序.供参考
%
% 输出文件'身份识别2.csv'的字段含义:依次为
% 发射时刻,导弹ID,导弹阵营,发射机ID,
% 发射机阵营,目标机ID,目标机阵营,数据场次
% 说明: 数据场次如果为k,则数据源文件为filenames{k}
% 来对应文件.
% 2023.12.11 版本
% 2023.12.18 更新.丰富了注释.
    
s2  = [91.163       99.399       102.19       100      95.187];
Rd2 = { };%存储读取原始文件的table数据

filenames = {'51st Bisons vs CNF Rd 1__1HZ.csv',...
    '51st Bisons vs CNF Rd 2__1HZ.csv',...
    '51st vs 36th R1__1HZ.csv',...
    '51st vs 36th R2__1HZ.csv',...
    '51st vs uvaf round 1__1HZ.csv'   }

for i=1:length(filenames)
    Rd2{i} = readtable(filenames{i});
end

%     {'Air+FixedWing'   }
%     {'Weapon+Missile'  }
%     {'Misc+Decoy+Chaff'}
%     {'Misc+Decoy+Flare'}
%     {'Misc+Container'  }
%     {'Misc+Shrapnel'   }

Data     = []; %
fa_table = [];%
for iii = 1:length(Rd2)%遍历各场数据
    Rd1 = Rd2{iii};
    %t0=table2array(Rd1(1,1));
    % Roll=table2array(Rd1(:,[6,7,8,9,20,27,28]));
    % d=all(~isnan(Roll),2);
    % Rd1=Rd1(d,:);% 去除缺失数据
    % m=size(Rd1);
    % id=table2array(Rd1(:,3))
    % s=tabulate(id)
    n = size(Rd1);
    %类别数据划分
    [Rd,p_type,s_type]   = huafen(Rd1,13)%13列为'Type'     
    %1:飞机
    idx1 = find(strcmp('Air+FixedWing',s_type(:,1)))   
    [Rd_air,p_air,s_air] = huafen(Rd{idx1},3); %3列为'Id'
    %2:导弹
    idx1 = find(strcmp('Weapon+Missile',s_type(:,1)))
    [Rd_mis,p_mis,s_mis] = huafen(Rd{idx1},3);
    % 本程序 未使用下列数据. 主要使用前面2个语句的数据
    %3:雷达干扰
    idx1 = find(strcmp('Misc+Decoy+Chaff',s_type(:,1)))
    [Rd_cha,p_cha,s_cha] = huafen(Rd{idx1},3);
    %4:红外干扰
    idx1 = find(strcmp('Misc+Decoy+Flare',s_type(:,1)))
    [Rd_fla,p_fla,s_fla] = huafen(Rd{idx1},3);
    %5:油箱
    idx1 = find(strcmp('Misc+Container',s_type(:,1)))
    [Rd_con,p_con,s_con] = huafen(Rd{idx1},3);
    %6:弹片
    idx1 = find(strcmp('Misc+Shrapnel',s_type(:,1)))
    [Rd_shr,p_shr,s_shr] = huafen(Rd{idx1},3);
   
    n_air = length(p_air); % 得到飞机数量
    n_mis = length(p_mis); % 得到导弹的数量
    n_cha = length(p_cha); % 其他信息
    n_fla = length(p_fla);
    n_con = length(p_con);
    n_shr = length(p_shr);
    %时间数据划分
    % [Rd_time,p_time,s_time]=huafen(Rd1,2);
    % n_time=length(p_time)
    %导弹发射机判断
    d   = zeros(n_mis,2);
    fa  = {};
    jie = {};
    for i=1:n_mis % 遍历各个弹的信息        
        time      = table2array(Rd_mis{i}(:,2));% Unix time
        data_mis  = Rd_mis{i}(1,:);% 导弹发射时刻的数据.
        local_mis = table2array(data_mis(:,4:6));%获取该导弹数据
        % cell2mat(table2array(data_mis(:,15)))
        % 15列为阵营 Coalition
        % 提取可能的发射机数据(可能涉及多个飞机)
        data_air  = Rd1(find(table2array(Rd1(:,2))==time(1)& ...%导弹发射时刻的飞机数据
            strcmp('Air+FixedWing',table2array(Rd1(:,13)))==1& ... % 记录为 飞机数据
            strcmp(cell2mat(table2array(data_mis(:,15))),table2array(Rd1(:,15)))==1),:); % 导弹、飞机的阵营相同
        % 提取可能的目标机数据（可能涉及多个飞机）
        data_air1 = Rd1(find(table2array(Rd1(:,2))==time(1)& ...
            strcmp('Air+FixedWing',table2array(Rd1(:,13)))==1&...
            strcmp(cell2mat(table2array(data_mis(:,15))),table2array(Rd1(:,15)))==0),:); % 导弹阵营、飞机阵营不相同的记录
        % 如果找不到发射机(应该不会出现这个)
        if size(data_air,1)==0 %如果找不到,可能是目标是己方阵营
            data_air = Rd1(find(table2array(Rd1(:,2))==time(1)&...
                strcmp('Air+FixedWing',table2array(Rd1(:,13)))==1),:); %可能的误射   
            %error('应该不会出现找不到发射机的情形')
        end
        % 如果找不到目标机(可能出现)
        if size(data_air1,1)==0 %如果找不到,可能是目标是己方阵营
            data_air1 = Rd1(find(table2array(Rd1(:,2))==time(1)&...
                strcmp('Air+FixedWing',table2array(Rd1(:,13)))==1),:); %不论阵营;把飞机都数据都提取出来
            %error('应该不会出现找不到目标机的情形')
        end        
        local_air  = table2array(data_air(:,4:6));%发射时刻发射机位置信息:经、纬、高
        local_air1 = table2array(data_air1(:,4:6));%发射时刻目标机位置信息
        [d(i,1),fa_id]  = min(distance(local_mis,local_air));% 找发射机id信息
        [d(i,2),jie_id] = min(distance(local_mis,local_air1));%找目标机id信息,排序最小导弹距离id
        %发射与目标机id
        fa_air   = table2array(data_air(fa_id,3));%提取Id
        jie_air  = table2array(data_air1(jie_id,3));%提取发射目标ID
        s_air1   = s_air;%cell2mat(s_air(:,1)); 
        % 提取发射机数据
        fa_data  = Rd_air{find(strcmp(s_air1,fa_air)==1)};
        % 提取目标机数据
        jie_data = Rd_air{find(strcmp(s_air1,jie_air)==1)};%提取存储对应飞机所有时序
        %导弹存在期间数据提取
        %% 提取发射前某个时刻数据(为后面找 规律有用; 只是找实体关系用不着)
        fa_data  = fa_data(table2array(fa_data(:,2))<=time(1)&...
            table2array(fa_data(:,2))>=time(1)-s2(iii),[2,6,7,8,9,20,27,28]);
        %% 提取发射后某个时刻数据
        jie_data = jie_data(table2array(jie_data(:,2))<=time(1)+s2(iii)&...
            table2array(jie_data(:,2))>=time(1),[2,6,7,8,9,20,27,28]); 
        % [2,6,7,8,9,20,27,28]各列分别对应下列数据:
        % Unixtime,Altitude,Roll,Pitch,Yaw,TAS,AOA,AOS
        % 提取发射机在导弹发射时刻数据
        fa_air   = data_air(fa_id,:);   
        % 提取目标机在导弹发射时刻数据 
        jie_air  = data_air1(jie_id,:); 
        %提取导弹发射前发射机机发射后目标机时序
        
        data_idarray = iii*ones(size(data_mis,2),1);
        % 构造每个导弹的结果表(逐行拼接)
        fa_table = [fa_table;
            %逐列含义:发射时刻,导弹Id,导弹Coalition,发射机Id,发射机Coalition,目标机Id,目标机Coalition,场次
            time(1),table2array(data_mis(:,[3,15])),table2array(fa_air(:,[3,15])),table2array(jie_air(:,[3,15])),iii];
        % 下面4行属于预处理操作(用于后续的建模用途)
        fa{i}    = table2array(fa_data);
        jie{i}   = table2array(jie_data);
        fa{i}(isnan(fa{i}))   = 0;
        jie{i}(isnan(jie{i})) = 0;
    end
end
writetable(array2table(fa_table),'实体身份识别.csv')
end
function d = distance(x1,x2)
% 计算两点空间距离(粗略估算,不准确).
% x1 为导弹的位置数据(三维向量)，表示实体1的经、纬、高.
% x2 为多个飞机的位置数据(n行3列矩阵)三值向量，
% 第1-3列依次为飞机的经、纬、高.每行为一个飞机的位置数据.
% 说明: 下面计算距离有专门公式.采用专门公式更准确.
% 也可以使用MATLAB的函数distance来计算.--distance是海拔高度应该是为0来计算的.
% 与我们这里还是有差异。

n=size(x2,1);
d=zeros(n,1);
x1(1:2)   = x1(1:2)/180*pi;   %导弹
x2(:,1:2) = x2(:,1:2)/180*pi; %多个飞机空间数据
%% 疑问1： 距离单位是公里还是米？6371是公里单位？
% 原始数据高度单位是米。
%% 疑问2：下列公式来源?
for i=1:n    
    theta = acos(sin(x1(2))*sin(x2(i,2))+cos(x1(2))*cos(x2(i,2))*cos(x1(1)-x2(i,1)));
    d(i)  = sqrt((6371*theta)^2+((x1(3)-x2(i,3))/1000)^2);
end
end

function [Rd,p,s_type]=huafen(Rd1,col_id)
% 把数据分类存到返回变量

% Rd1 为原始数据的table型变量
% col_id 为列数. col_id 也可以是列标题.

type  = table2array(Rd1(:,col_id));
s_type= tabulate(type);% 频率表: 第1-3列依次为 '值' '频数' '频率*100'
m     = size(s_type,1);
Rd    = {};%（1:飞机,2:导弹,3:雷达干扰,4:红外干扰,5:油箱,6:弹片）
p     = zeros(m,1);
for i=1:m
    j     = find(strcmp(s_type{i},type) == 1);
    p(i)  = length(j);
    Rd{i} = Rd1(j,:);
end
end
