%% 输出发射机与目标机，写成csv
%具体的运行地址（的前半部分）——根据自己的文件夹调整
loc = "D:\和学校有关的，所有\数据科学中的数学方法\三、仿真数据挖掘\附件1-1Hz\";
str_load
for i = 1:5
    [LauR_Id,TarR_Id,LauB_Id,TarB_Id,tableR,tableB]=Missile_IDE(str(i));
    path_red = strcat(loc,str(i),'\Weapon\Red');
    path_blue = strcat(loc,str(i),'\Weapon\Blue');
    
    %把导弹名称带上
    cd(path_red);
    %获取这个文件夹下的所有文件（表格），并排除那些谜之隐藏文件
    fileList = dir(path_red);
    fileList = fileList(~startsWith({fileList.name}, '.'));
    %获取这些表格的名称，用字符串格式
    misNamesR = {fileList.name};
    misNamesR = string(misNamesR);
    misNamesR = erase(misNamesR,".csv");
    misNamesR = misNamesR';
    
    cd(path_blue);
    %获取这个文件夹下的所有文件（表格），并排除那些谜之隐藏文件
    fileList = dir(path_blue);
    fileList = fileList(~startsWith({fileList.name}, '.'));
    %获取这些表格的名称，用字符串格式
    misNamesB = {fileList.name};
    misNamesB = string(misNamesB);
    misNamesB = erase(misNamesB,".csv");
    misNamesB = misNamesB';
    
    %把导弹名称和对应发射、目标机列为一张表
    orderR = 1:length(misNamesR);    orderR = orderR';
    LauTarR = table(orderR,misNamesR,LauR_Id,TarR_Id);
    LauTarR.Properties.VariableNames = {'Order','Missile_R','Launcher_R','Target_R'};
    writetable(LauTarR,strcat(loc,str(i),'\Weapon\LauTarR.csv'));
    
    orderB = 1:length(misNamesB);    orderB = orderB';
    LauTarB = table(orderB,misNamesB,LauB_Id,TarB_Id);
    LauTarB.Properties.VariableNames = {'Order','Missile_B','Launcher_B','Target_B'};
    writetable(LauTarB,strcat(loc,str(i),'\Weapon\LauTarB.csv'));
end
    
    