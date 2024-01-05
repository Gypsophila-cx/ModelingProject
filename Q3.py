import pandas as pd
import numpy as np
from tmp_1 import solve_3_1
from tmp_1 import calc_b

def calc_yaw(yaw): # 计算偏航角的变化量
    len_ = len(yaw)
    sum = 0
    for i in range(1, len_):
        if np.abs(yaw[i] - yaw[i - 1]) > 300: 
            # 由于偏航角是一个周期性变化的量，所以需要考虑跨越360度的情况，例如：359度到0度的变化量为1度，而不是359度，通过观察数据发现，变化量大于300度时，可以保证跨越了360度
            sum += min(yaw[i], yaw[i - 1]) + 360 - max(yaw[i], yaw[i - 1])
        else:
            sum += np.abs(yaw[i] - yaw[i - 1])

    return sum
    
def decide_action(yaw, pitch, roll, altitude, actions):
    len_ = len(yaw)
    acts = [0, 0, 0, 0, 0] # 储存基本动作，分别为：平飞、上升、下降、转弯、翻滚，出现为1，否则为0
    
    # 统计区间内基本动作
    for a in actions:
        while a >= 1:
            acts[int(a % 10) - 1] += 1
            a = int(a / 10)

    # 判定定常盘旋
    threshold = 0.5
    height_threshold = 20
    roll_threshold = 10
    yaw_threshold = 10

    if acts[3] > 0 and calc_yaw(yaw=yaw) > 360 * threshold and np.max(altitude) - np.min(altitude) < height_threshold and np.min(np.abs(roll)) > roll_threshold:
        return 1
    
    # 判定急盘降
    altitude_b, _ = calc_b(altitude)
    if acts[3] > 0 and acts[2] > 0 and calc_yaw(yaw=yaw) > 360 * threshold and np.max(altitude) - np.min(altitude) > height_threshold and altitude_b < 0:
        return 2
    
    # 判定急盘升
    if acts[3] > 0 and acts[1] > 0 and calc_yaw(yaw=yaw) > 360 * threshold and np.max(altitude) - np.min(altitude) > height_threshold and altitude_b > 0:
        return 3
    
    # 判定俯冲
    if acts[2] > 0 and calc_yaw(yaw) < yaw_threshold and np.max(altitude) - np.min(altitude) > height_threshold and altitude_b < 0:
        return 4
    
    # 判定急拉起
    if acts[1] > 0 and calc_yaw(yaw) < yaw_threshold and np.max(altitude) - np.min(altitude) > height_threshold and altitude_b > 0:
        return 5
    
    # 判定半斤斗
    if acts[1] + acts[2] > 0 and np.max(pitch) - np.min(pitch) > 180 * threshold and np.max(roll) - np.min(roll) < roll_threshold:
        return 6
    
    # 判定半滚倒转
    if acts[1] + acts[2] > 0 and np.max(pitch) - np.min(pitch) > 180 * threshold and np.max(roll) - np.min(roll) > 180 * threshold:
        return 7
    
    # 判定滚筒
    if acts[4] > 0 and np.max(altitude) - np.min(altitude) < height_threshold and calc_yaw(yaw) < yaw_threshold and np.max(roll) - np.min(roll) > 180 *threshold:
        return 8
    
    # 判定战术转弯
    yaw_slope_threshold = 5
    yaw_b, _ = calc_b(yaw)
    if acts[3] > 0 and yaw_b > yaw_slope_threshold and calc_yaw(yaw) < 90 *threshold:
        return 9
    
    # 判定规避急转弯
    if acts[3] > 0 and yaw_b > yaw_slope_threshold and calc_yaw(yaw) > 90 *threshold:
        return 10
    
    # 判定低速 yoyo
    if acts[1] + acts[4] > 0 and altitude_b > 0 and np.max(roll) - np.min(roll) > 180 *threshold:
        return 12
    
    # 判定高速 yoyo
    if acts[2] + acts[4] > 0 and altitude_b < 0 and np.max(roll) - np.min(roll) > 180 *threshold:
        return 11
    
    return np.argmax(acts) + 13

name = '51st vs 36th R1__1HZ.csv'
file_name = 'D:\\Study\\Computing\\发射机与目标机判定\\ques2_' + name
origin_name = 'D:\\Study\\Computing\\发射机与目标机判定\\data\\' + name
file = pd.read_csv(file_name)
origin = pd.read_csv(origin_name)

YAW = origin['Yaw'].values
ROLL = origin['Roll'].values
PITCH = origin['Pitch'].values
ALTITUDE = origin['Altitude'].values

time_min = origin['Unix time'].min()
time_max = origin['Unix time'].max()
df = pd.DataFrame(index=range(time_max - time_min + 30))
df = df.astype('object')

flag = 0

for ids in list(file.columns.values):
    flag += 1
    if flag == 1:
        continue
    data = file[ids].values # 指定飞机的基本动作序列，
    # .values将DataFrame转换为ndarray，其中元素类型从object转换为int
    intervals = solve_3_1(data) # 将基本动作序列划分为一串子序列，每一段子序列组成一个复杂动作
    actions = [] # 保存研究区间内的动作序列

    for interval in intervals:
        start, end = interval.split('-') # interval的格式为'起始时刻-终止时刻'
        start, end = int(start), int(end) # 将起始时刻和终止时刻转换为整数

        # 通过判断区间内的基本动作序列，确定区间内的复杂动作
        action = decide_action(
            yaw=YAW[start:end+1],
            roll=ROLL[start:end+1],
            pitch=PITCH[start:end+1],
            altitude=ALTITUDE[start:end+1],
            actions=data[start:end+1])
        
        for i in range(end - start + 1):
            actions.append(action) # 将复杂动作序列添加到动作序列中

    df[ids] = '0'
    ff = origin[origin.Id == ids]
    start_time = ff.iloc[0, 1] - time_min

    df.loc[start_time: start_time+len(actions)-1, name] = actions #! -1
    df.loc[start_time+len(actions):, name] = -1
    
tttmp = 'ques3_1_' + name
df.to_csv(tttmp)