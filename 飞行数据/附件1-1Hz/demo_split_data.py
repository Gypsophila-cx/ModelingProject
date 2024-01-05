#coding=utf-8
"""
    读取实体csv文件示例代码.
    
    更新于 2023.05.11
    YZ.
"""
import os
import pandas as pd
import matplotlib.pyplot as plt


def draw_entity(df):
    """
    绘制飞机实体的某些特征的时序图.

    df 为一个实体的数据.
    
    plt.plot(x, y, color='green'
    """
    plt.subplot(221)
    plt.plot(df.loc[:,'Time'],df.loc[:,'Altitude'], c='red') # 海拔高度
    plt.ylabel('Altitude')

    plt.subplot(222)
    plt.plot(df.loc[:, 'Time'], df.loc[:, 'TAS'], c='red')   # 真空速 TAS
    plt.ylabel('TAS')

    plt.subplot(223)
    plt.plot(df.loc[:, 'Time'], df.loc[:, 'Pitch'], c='red') # 俯仰角
    plt.ylabel('Pitch')

    plt.subplot(224)
    plt.plot(df.loc[:, 'Time'], df.loc[:, 'Roll'], c='red')  # 滚转角
    plt.ylabel('Roll')

    # 可以绘制其他特征.
    
    #plt.show()

def split_entity(filename):
    """
        此函数用于读取tacview导出的遥测数据的csv格式文件.
        主要返回所有飞机id的列表,导弹id的列表,
    """
    df = pd.read_csv(filename,sep=',')
    #此处可以对字段名称进行标准化处理
    dic = { "ISO time": "IsoTime", "Unix time": "Time", "Air Distance": "Adis","Ground Distance":"Gdis"}

    df.rename(columns = dic, inplace=True)
    
    # 获取全部实体的id, 通过unique()某个字段的唯一值
    ids_plane = df.loc[df.loc[:,'Type']=='Air+FixedWing','Id'].unique()
    ids_missile  = df.loc[df.loc[:,'Type']=='Weapon+Missile','Id'].unique()

    minunixtime      = df.loc[df.loc[:, 'Type'] == 'Air+FixedWing', 'Time'].min()

    # 处理时间字段,转换为起始时刻为0时刻
    df.loc[:,'Time'] = df.loc[:,'Time'] - minunixtime # 时间处理:最小值从0开始

    # 提取某个实体看到时序数据

    print('plane ids:',type(ids_plane))
    print(ids_plane)
    print('missile ids:',type(ids_missile))
    print(ids_missile)

    df_data = { } # 飞机、导弹数据都保存到该字典中

    # 提取出飞机实体数据
    for id in ids_plane: # 遍历飞机id,每个飞机的数据保存到一个DataFrame当中.所有飞机数据保存到一个字典对象.key为飞机id,value为包含飞机的时序数据
        df_data[id] = df.loc[df.loc[:,'Id']==id,:]
        print('-'*80)
        print(' '*30 + ' plane id:' + id)
        print('-'*80)
        print(df_data[id])

    # 提取出导弹实体数据
    for id in ids_missile: # 遍历导弹id,每个导弹的数据保存到一个DataFrame当中.所有导弹数据保存到一个字典对象.key为导弹id,value为包含导弹的时序数据
        df_data[id] = df.loc[df.loc[:,'Id']==id,:]
        print('-'*80)
        print(' '*30 + ' missile id:' + id)
        print('-'*80)
        print(df_data[id])    
    
    return [ids_plane,ids_missile,df_data]

if __name__ == '__main__':

    path     = './'                               #   实体csv文件存放路径
    filename = '51st Bisons vs CNF Rd 1__1HZ.csv' # 实体csv文件名称
    
    filename = os.path.join(path,filename)        # 获得
    
    [ids_plane,ids_missile,data] = split_entity(filename)

    plt.ion() # 启用交互模式
    for id in ids_plane:
        plt.figure()
        draw_entity(data[id])

    #plt.ioff()
    plt.show()
    plt.close('all')
    print('读取数据，并结束显示。')

    plt.ioff()
    
