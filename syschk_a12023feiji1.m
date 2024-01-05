function a12023feiji1
% Team 16. ��ʵ���ϵ�ĳ���.���ο�
%
% ����ļ�'���ʶ��2.csv'���ֶκ���:����Ϊ
% ����ʱ��,����ID,������Ӫ,�����ID,
% �������Ӫ,Ŀ���ID,Ŀ�����Ӫ,���ݳ���
% ˵��: ���ݳ������Ϊk,������Դ�ļ�Ϊfilenames{k}
% ����Ӧ�ļ�.
% 2023.12.11 �汾
% 2023.12.18 ����.�ḻ��ע��.
    
s2  = [91.163       99.399       102.19       100      95.187];
Rd2 = { };%�洢��ȡԭʼ�ļ���table����

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
for iii = 1:length(Rd2)%������������
    Rd1 = Rd2{iii};
    %t0=table2array(Rd1(1,1));
    % Roll=table2array(Rd1(:,[6,7,8,9,20,27,28]));
    % d=all(~isnan(Roll),2);
    % Rd1=Rd1(d,:);% ȥ��ȱʧ����
    % m=size(Rd1);
    % id=table2array(Rd1(:,3))
    % s=tabulate(id)
    n = size(Rd1);
    %������ݻ���
    [Rd,p_type,s_type]   = huafen(Rd1,13)%13��Ϊ'Type'     
    %1:�ɻ�
    idx1 = find(strcmp('Air+FixedWing',s_type(:,1)))   
    [Rd_air,p_air,s_air] = huafen(Rd{idx1},3); %3��Ϊ'Id'
    %2:����
    idx1 = find(strcmp('Weapon+Missile',s_type(:,1)))
    [Rd_mis,p_mis,s_mis] = huafen(Rd{idx1},3);
    % ������ δʹ����������. ��Ҫʹ��ǰ��2����������
    %3:�״����
    idx1 = find(strcmp('Misc+Decoy+Chaff',s_type(:,1)))
    [Rd_cha,p_cha,s_cha] = huafen(Rd{idx1},3);
    %4:�������
    idx1 = find(strcmp('Misc+Decoy+Flare',s_type(:,1)))
    [Rd_fla,p_fla,s_fla] = huafen(Rd{idx1},3);
    %5:����
    idx1 = find(strcmp('Misc+Container',s_type(:,1)))
    [Rd_con,p_con,s_con] = huafen(Rd{idx1},3);
    %6:��Ƭ
    idx1 = find(strcmp('Misc+Shrapnel',s_type(:,1)))
    [Rd_shr,p_shr,s_shr] = huafen(Rd{idx1},3);
   
    n_air = length(p_air); % �õ��ɻ�����
    n_mis = length(p_mis); % �õ�����������
    n_cha = length(p_cha); % ������Ϣ
    n_fla = length(p_fla);
    n_con = length(p_con);
    n_shr = length(p_shr);
    %ʱ�����ݻ���
    % [Rd_time,p_time,s_time]=huafen(Rd1,2);
    % n_time=length(p_time)
    %����������ж�
    d   = zeros(n_mis,2);
    fa  = {};
    jie = {};
    for i=1:n_mis % ��������������Ϣ        
        time      = table2array(Rd_mis{i}(:,2));% Unix time
        data_mis  = Rd_mis{i}(1,:);% ��������ʱ�̵�����.
        local_mis = table2array(data_mis(:,4:6));%��ȡ�õ�������
        % cell2mat(table2array(data_mis(:,15)))
        % 15��Ϊ��Ӫ Coalition
        % ��ȡ���ܵķ��������(�����漰����ɻ�)
        data_air  = Rd1(find(table2array(Rd1(:,2))==time(1)& ...%��������ʱ�̵ķɻ�����
            strcmp('Air+FixedWing',table2array(Rd1(:,13)))==1& ... % ��¼Ϊ �ɻ�����
            strcmp(cell2mat(table2array(data_mis(:,15))),table2array(Rd1(:,15)))==1),:); % �������ɻ�����Ӫ��ͬ
        % ��ȡ���ܵ�Ŀ������ݣ������漰����ɻ���
        data_air1 = Rd1(find(table2array(Rd1(:,2))==time(1)& ...
            strcmp('Air+FixedWing',table2array(Rd1(:,13)))==1&...
            strcmp(cell2mat(table2array(data_mis(:,15))),table2array(Rd1(:,15)))==0),:); % ������Ӫ���ɻ���Ӫ����ͬ�ļ�¼
        % ����Ҳ��������(Ӧ�ò���������)
        if size(data_air,1)==0 %����Ҳ���,������Ŀ���Ǽ�����Ӫ
            data_air = Rd1(find(table2array(Rd1(:,2))==time(1)&...
                strcmp('Air+FixedWing',table2array(Rd1(:,13)))==1),:); %���ܵ�����   
            %error('Ӧ�ò�������Ҳ��������������')
        end
        % ����Ҳ���Ŀ���(���ܳ���)
        if size(data_air1,1)==0 %����Ҳ���,������Ŀ���Ǽ�����Ӫ
            data_air1 = Rd1(find(table2array(Rd1(:,2))==time(1)&...
                strcmp('Air+FixedWing',table2array(Rd1(:,13)))==1),:); %������Ӫ;�ѷɻ������ݶ���ȡ����
            %error('Ӧ�ò�������Ҳ���Ŀ���������')
        end        
        local_air  = table2array(data_air(:,4:6));%����ʱ�̷����λ����Ϣ:����γ����
        local_air1 = table2array(data_air1(:,4:6));%����ʱ��Ŀ���λ����Ϣ
        [d(i,1),fa_id]  = min(distance(local_mis,local_air));% �ҷ����id��Ϣ
        [d(i,2),jie_id] = min(distance(local_mis,local_air1));%��Ŀ���id��Ϣ,������С��������id
        %������Ŀ���id
        fa_air   = table2array(data_air(fa_id,3));%��ȡId
        jie_air  = table2array(data_air1(jie_id,3));%��ȡ����Ŀ��ID
        s_air1   = s_air;%cell2mat(s_air(:,1)); 
        % ��ȡ���������
        fa_data  = Rd_air{find(strcmp(s_air1,fa_air)==1)};
        % ��ȡĿ�������
        jie_data = Rd_air{find(strcmp(s_air1,jie_air)==1)};%��ȡ�洢��Ӧ�ɻ�����ʱ��
        %���������ڼ�������ȡ
        %% ��ȡ����ǰĳ��ʱ������(Ϊ������ ��������; ֻ����ʵ���ϵ�ò���)
        fa_data  = fa_data(table2array(fa_data(:,2))<=time(1)&...
            table2array(fa_data(:,2))>=time(1)-s2(iii),[2,6,7,8,9,20,27,28]);
        %% ��ȡ�����ĳ��ʱ������
        jie_data = jie_data(table2array(jie_data(:,2))<=time(1)+s2(iii)&...
            table2array(jie_data(:,2))>=time(1),[2,6,7,8,9,20,27,28]); 
        % [2,6,7,8,9,20,27,28]���зֱ��Ӧ��������:
        % Unixtime,Altitude,Roll,Pitch,Yaw,TAS,AOA,AOS
        % ��ȡ������ڵ�������ʱ������
        fa_air   = data_air(fa_id,:);   
        % ��ȡĿ����ڵ�������ʱ������ 
        jie_air  = data_air1(jie_id,:); 
        %��ȡ��������ǰ������������Ŀ���ʱ��
        
        data_idarray = iii*ones(size(data_mis,2),1);
        % ����ÿ�������Ľ����(����ƴ��)
        fa_table = [fa_table;
            %���к���:����ʱ��,����Id,����Coalition,�����Id,�����Coalition,Ŀ���Id,Ŀ���Coalition,����
            time(1),table2array(data_mis(:,[3,15])),table2array(fa_air(:,[3,15])),table2array(jie_air(:,[3,15])),iii];
        % ����4������Ԥ�������(���ں����Ľ�ģ��;)
        fa{i}    = table2array(fa_data);
        jie{i}   = table2array(jie_data);
        fa{i}(isnan(fa{i}))   = 0;
        jie{i}(isnan(jie{i})) = 0;
    end
end
writetable(array2table(fa_table),'ʵ�����ʶ��.csv')
end
function d = distance(x1,x2)
% ��������ռ����(���Թ���,��׼ȷ).
% x1 Ϊ������λ������(��ά����)����ʾʵ��1�ľ���γ����.
% x2 Ϊ����ɻ���λ������(n��3�о���)��ֵ������
% ��1-3������Ϊ�ɻ��ľ���γ����.ÿ��Ϊһ���ɻ���λ������.
% ˵��: ������������ר�Ź�ʽ.����ר�Ź�ʽ��׼ȷ.
% Ҳ����ʹ��MATLAB�ĺ���distance������.--distance�Ǻ��θ߶�Ӧ����Ϊ0�������.
% ���������ﻹ���в��졣

n=size(x2,1);
d=zeros(n,1);
x1(1:2)   = x1(1:2)/180*pi;   %����
x2(:,1:2) = x2(:,1:2)/180*pi; %����ɻ��ռ�����
%% ����1�� ���뵥λ�ǹ��ﻹ���ף�6371�ǹ��ﵥλ��
% ԭʼ���ݸ߶ȵ�λ���ס�
%% ����2�����й�ʽ��Դ?
for i=1:n    
    theta = acos(sin(x1(2))*sin(x2(i,2))+cos(x1(2))*cos(x2(i,2))*cos(x1(1)-x2(i,1)));
    d(i)  = sqrt((6371*theta)^2+((x1(3)-x2(i,3))/1000)^2);
end
end

function [Rd,p,s_type]=huafen(Rd1,col_id)
% �����ݷ���浽���ر���

% Rd1 Ϊԭʼ���ݵ�table�ͱ���
% col_id Ϊ����. col_id Ҳ�������б���.

type  = table2array(Rd1(:,col_id));
s_type= tabulate(type);% Ƶ�ʱ�: ��1-3������Ϊ 'ֵ' 'Ƶ��' 'Ƶ��*100'
m     = size(s_type,1);
Rd    = {};%��1:�ɻ�,2:����,3:�״����,4:�������,5:����,6:��Ƭ��
p     = zeros(m,1);
for i=1:m
    j     = find(strcmp(s_type{i},type) == 1);
    p(i)  = length(j);
    Rd{i} = Rd1(j,:);
end
end
