%% 从一场战斗中提取各架飞机与导弹的单独信息
function DataSplit(str)
%具体的绝对输出地址（的前半部分）
loc = "D:\和学校有关的，所有\数据科学中的数学方法\三、仿真数据挖掘\附件1-1Hz\";
%Id一列既有纯数字，又有字符串，这里统一用字符串格式读入
opts = detectImportOptions(strcat(str,'.csv'));
opts = setvartype(opts,{'Id'},'char');
Data = readtable(strcat(str,'.csv'),opts);
%找到所有的飞机=Air和所有的导弹=Weapon，单独拉成一张表格
air_log = (Data.Type=="Air+FixedWing");
weapon_log = (Data.Type=="Weapon+Missile");
Air = Data(air_log,:);
Weapon = Data(weapon_log,:);

%% 根据Id不同与阵营的不同，划出所有飞机的单独表格（以csv格式存储）
air_id = string(unique(Air.Id));
weapon_id = string(unique(Weapon.Id));

for i=1:length(air_id)
    log_ind = (Air.Id==air_id(i));
    Air_temp = Air(log_ind,:);
    %在Data中应该只有红、蓝、紫三种颜色，其中紫色是杂项，只有红蓝是阵营
    %所以只用判断红色还是蓝色
    if string(Air_temp.Color) == 'Red'
        writetable(Air_temp,strcat(loc,str,'\Air\Red\',air_id(i),'.csv'));
    end
    if string(Air_temp.Color) == 'Blue'
        writetable(Air_temp,strcat(loc,str,'\Air\Blue\',air_id(i),'.csv'));
    end
end
for i=1:length(weapon_id)
    log_ind = (Weapon.Id==weapon_id(i));
    Weapon_temp = Weapon(log_ind,:);
    if string(Weapon_temp.Color) == 'Red'
        writetable(Weapon_temp,strcat(loc,str,'\Weapon\Red\',weapon_id(i),'.csv'))
    end
    if string(Weapon_temp.Color) == 'Blue'
        writetable(Weapon_temp,strcat(loc,str,'\Weapon\Blue\',weapon_id(i),'.csv'))
    end
    %令人惊讶的，居然还有中立的导弹
    if string(Weapon_temp.Color) == 'Violet'
        writetable(Weapon_temp,strcat(loc,str,'\Weapon\Violet\',weapon_id(i),'.csv'))
    end
end