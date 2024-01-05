import pandas as pd
import numpy as np
from tmp_1 import solve_3_1
from tmp_1 import calc_b

def calc_yaw(yaw):
    len_ = len(yaw)
    sum = 0
    for i in range(1, len_):
        if np.abs(yaw[i] - yaw[i - 1]) > 300:
            sum += 5
        else:
            sum += np.abs(yaw[i] - yaw[i - 1])
        return sum
    
def decide_action(yaw, pitch, roll, altitude, actions):
    len_ = len(yaw)
    acts = [0, 0, 0, 0, 0]
    
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

name = '51st vs 36th R2__1HZ.csv'
file_name = 'D:\\Study\\Computing\\发射机与目标机判定\\data\\ques2_' + name
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
    data = file[ids].values
    intervals = solve_3_1(data)
    actions = []

    for interval in intervals:
        start, end = interval.split('-')
        start, end = int(start), int(end)
        action = decide_action(
            yaw=YAW[start:end+1],
            roll=ROLL[start:end+1],
            pitch=PITCH[start:end+1],
            altitude=ALTITUDE[start:end+1],
            actions=data[start:end+1])
        
        for i in range(end - start + 1):
            actions.append(action)

    df[ids] = '0'
    ff = origin[origin.Id == ids]
    start_time = ff.iloc[0, 1] - time_min
    for i in range(df.shape[0] - len(actions) - start_time):
        actions.append(-1)
    df.loc[start_time:, ids] = actions
    
tttmp = 'ques3_1_' + name
df.to_csv(tttmp)