from sklearn.linear_model import LinearRegression
import pandas as pd
import numpy as np

# y = b * x + a
def calc_b(y):
    reg = LinearRegression()
    len_ = len(y)
    y = y.reshape(-1, 1)
    x = [i for i in range(1, len_ + 1)]
    x = np.array(x)
    x = x.reshape(-1, 1)
    reg.fit(x, y)
    return reg.coef_, reg.score(x, y)

def decide_basic_action(yaw, pitch, roll, ground_dist):
    yaw_b, yaw_r2 = calc_b(yaw)
    pitch_b, pitch_r2 = calc_b(pitch)
    roll_b, roll_r2 = calc_b(roll)
    ground_dist_b, ground_dist_r2 = calc_b(ground_dist)

    threshold = 0.95
    if yaw_r2 < threshold or pitch_r2 < threshold or roll_r2 < threshold or ground_dist_r2 < threshold:
        return 0

    ans = []
    if (yaw_b > -1) and (yaw_b < 1) and (ground_dist_b > -2) and (ground_dist_b < 2):
        ans.append(1)
    if ground_dist_b > 2:
        ans.append(2)
    if ground_dist_b < -2:
        ans.append(3)
    if yaw_b > 1:
        ans.append(4)
    if roll_b > 10:
        ans.append(5)
    if len(ans) == 0:
        return 0
    else:
        return ans
    
original_filename = '51st vs 36th R1__1HZ.csv'
ttmp = 'D:\\Study\\Computing\\发射机与目标机判定\\data\\' + original_filename
original_file = pd.read_csv(ttmp)
Ids = original_file['Id'].values
names = []

time_min = original_file['Unix time'].min()
time_max = original_file['Unix time'].max()

time_file_name = original_filename + '_time' + '.txt'

df = pd.DataFrame(index=range(time_max - time_min + 30))
for Id in Ids:
    found = False
    type_name = original_file.loc[original_file['Id'] == Id]['Type'].values[0]
    if type_name.find('Air') == -1:
        continue
    for name in names:
        if Id == name:
            found = True
            break
    if not found:
        names.append(Id)

for name in names:
    acts = []
    file = original_file[original_file.Id == name]
    start_time = file.iloc[0, 1] - time_min
    roll = file['Roll'].values
    roll = np.array(roll)
    pitch = file['Pitch'].values
    pitch = np.array(pitch)
    yaw = file['Yaw'].values
    yaw = np.array(yaw)
    ground_distance = file['Altitude'].values
    ground_distance = np.array(ground_distance)

    start = 0
    end = len(roll)
    cur = 0
    default_sliding_window_len = 10

    while cur < end:
        begin = cur
        sliding_window_len = default_sliding_window_len
        act = decide_basic_action(
            yaw=yaw[begin:begin + sliding_window_len], 
            pitch=pitch[begin:begin + sliding_window_len],
            roll=roll[begin:begin + sliding_window_len],
            ground_dist=ground_distance[begin:begin + sliding_window_len]
            )
        
        while act == 0:
            sliding_window_len -= 1
            act = decide_basic_action(
                yaw=yaw[begin:begin + sliding_window_len],
                pitch=pitch[begin:begin + sliding_window_len],
                roll=roll[begin:begin + sliding_window_len],
                ground_dist=ground_distance[begin:begin + sliding_window_len]
                )
            
        for i in range(sliding_window_len):
            tmp = ''
            for a in act:
                tmp += str(a)
            acts.append(tmp)
        cur += sliding_window_len

        for i in range(df.shape[0] - len(acts) - start_time):
            acts.append('-1')

        df = df.astype('object')
        df[name] = '0'
        df.loc[start_time:, name] = acts
        
print(df)
tttmp = 'ques2_' + original_filename
df.to_csv(tttmp)