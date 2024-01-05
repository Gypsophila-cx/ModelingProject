import numpy as np
import pandas as pd
import math
import sympy

R = 6371004

def calc_descartes_jd(jd, wd, h):
    jd = jd / 180 * math.pi
    wd = wd / 180 * math.pi

    return (R + h) * math.cos(jd) * math.cos(wd), (h + R) * math.sin(jd) * math.cos(wd), (h + R) * math.sin(jd)

def calc_descartes_hd(jd, wd, h):
    return h * math.cos(jd) * math.cos(wd), h * math.sin(jd) * math.cos(wd), h * math.sin(jd)

def calc_phi(jd1, wd1, jd2, wd2):
    x1, y1, z1 = calc_descartes_jd(jd1, wd1, 1)
    x2, y2, z2 = calc_descartes_jd(jd2, wd2, 1)
    x3, y3, z3 = calc_descartes_jd(jd1, wd2, 1)
    dis1 = math.sqrt(math.pow(x1 - x3, 2) + math.pow(y1 - y3, 2) + math.pow(z1 - z3, 2))
    dis2 = math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2) + math.pow(z1 - z2, 2))

    return math.acos(dis1 / dis2)

def calc_v_zv(jd, wd, gd, yaw):
    jd = jd / 180 * math.pi
    wd = wd / 180 * math.pi
    yaw = yaw / 180 * math.pi
    q = (gd + R) / math.cos(wd)
    x, y, z = calc_descartes_hd(jd, wd, gd)
    dis = math.sqrt(math.pow(0 - x, 2) + math.pow(0 - y, 2) + math.pow(q - z, 2))
    zv = dis * math.cos(yaw) / (gd + R) * math.cos(wd)
    return zv, x, y, z

def calc_v_sympy(jd, wd, gd, yaw):
    zv, x2, y2, z2 = calc_v_zv(jd, wd, gd, yaw)
    xv = sympy.Symbol('xv')
    yv = sympy.Symbol('yv')
    eq1 = x2 * xv + y2 * yv + z2 * zv
    eq2 = xv * xv + yv * yv + zv * zv - 1
    root = sympy.solve([eq1, eq2], [xv, yv])
    return root[0][0], root[0][1], zv

def calc_v_quick(jd, wd, gd, yaw):
    zv, x2, y2, z2 = calc_v_zv(jd, wd, gd, yaw)
    tmp = math.pow(z2 * x2 * zv, 2) - (math.pow(x2, 2) + math.pow(y2, 2)) * ((math.pow(zv, 2) - 1) * math.pow(y2, 2) + math.pow(z2, 2) * math.pow(zv, 2))

    if tmp <= 0:
        return 0.33, 0.33, 0.34
    
    xv = (- z2 * x2 * zv + math.sqrt(tmp)) / (math.pow(x2, 2) + math.pow(y2, 2))
    yv = - (z2 * zv + x2 * xv) / y2

    return xv, yv, zv

def calc_q(jd1, wd1, gd1, jd2, wd2, gd2, yaw):
    xv, yv, zv = calc_v_quick(jd2, wd2, gd2, yaw)
    x1, y1, z1 = calc_descartes_jd(jd1, wd1, gd1)
    x2, y2, z2 = calc_descartes_jd(jd2, wd2, gd2)

    t1 = (x2 - x1) / math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2) + math.pow(z2 - z1, 2))

    t2 = (y2 - y1) / math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2) + math.pow(z2 - z1, 2))

    t3 = (z2 - z1) / math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2) + math.pow(z2 - z1, 2))

    tmp = xv * t1 + yv * t2 + zv * t3

    return math.acos(tmp)

def calc_ra(phi, q):
    return 1 - (math.fabs(phi) + math.fabs(q)) / math.pi

def calc_rd(jd1, wd1, gd1, jd2, wd2, gd2):
    x1, y1, z1 = calc_descartes_jd(jd1, wd1, gd1)
    x2, y2, z2 = calc_descartes_jd(jd2, wd2, gd2)
    dis = math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2) + math.pow(z1 - z2, 2))
    d_max = 30000

    return math.exp(- dis * math.log(2, math.e) / d_max)

def calc_rf(color, time):
    data = origin.loc[origin['Unix time'] == time]
    cnt = 0
    for i in range(data.shape[0]):
        if data.iloc[i, 13] == color and 'Weapon' in data.iloc[i, 12]:
            cnt += 1

    return cnt

def calc_rv(v1, v2):
    if v1 < 0.6 * v2:
        return 0.1
    elif 0.6 * v2 <= v1 <= 1.5 * v2:
        if v1 <= 0.0001:
            return 1
        return -0.5 + v1 / v2
    else:
        return 1
    
def calc_rh(h1, h2):
    if h1 - h2 <= -5000:
        return 0
    elif -5000 <= h1 - h2 <= 5000:
        return 0.5 + 0.1 * (h1 - h2) / 1000
    else:
        return 1
    
name = '51stKIAP_vs_107th_Round_1.csv'
file_name = 'ques2_' + name
origin_name = './data/' + name
file = pd.read_csv(file_name)
origin = pd.read_csv(origin_name)
enemies = {'Red': 'Blue', 'Blue': 'Red'}
ids = list(file.columns.values)
print(ids)

ids = ids[1:]
colors = {}

for id in ids:
    cor_file = origin.loc[origin['Id'] == id]
    colors[id] = cor_file['Color'].values[2]

coloms = {}
sdsadsd = 0

for col in list(origin.columns.values):
    coloms[col] = sdsadsd
    sdsadsd += 1


def solve(id, time):
    color = colors[id]
    enemy = enemies[color]
    all_enemy_data = origin.loc[(origin['Unix time'] == time) & (origin['Color'] == enemy)]
    my_data = origin.loc[(origin['Unix time'] == time) & (origin['Id'] == id)]

    if my_data.shape[0] == 0:
        return 0
    
    jd1 = my_data.iloc[0, coloms['Longitude']]
    wd1 = my_data.iloc[0, coloms['Latitude']]
    gd1 = my_data.iloc[0, coloms['Altitude']]
    v1 = my_data.iloc[0, coloms['TAS']]
    ra = 0
    rd = 0
    rf = 0
    rv = 0
    rh = 0

    for i in range(all_enemy_data.shape[0]):
        jd2 = all_enemy_data.iloc[i, coloms['Longitude']]
        wd2 = all_enemy_data.iloc[i, coloms['Latitude']]
        gd2 = all_enemy_data.iloc[i, coloms['Altitude']]
        v2 = all_enemy_data.iloc[i, coloms['TAS']]
        yaw = all_enemy_data.iloc[i, coloms['Yaw']]

        phi = calc_phi(jd1, wd1, jd2, wd2)
        q = calc_q(jd1, wd1, gd1, jd2, wd2, gd2, yaw)

        ra += calc_ra(phi, q)

        rd += calc_rd(jd1, wd1, gd1, jd2, wd2, gd2)

        rf += calc_rf(colors[id], time)

        rh += calc_rh(gd1, gd2)

        rv += calc_rv(v1, v2)

    return (ra * 0.25 + rd * 0.1 + rf * 0.15 + rh * 0.25 + rv * 0.25) / all_enemy_data.shape[0]

time_min = origin['Unix time'].values[0]
time_max = origin['Unix time'].values[-1]
df = pd.DataFrame(index=range(time_min, time_max + 30))
df = df.astype('object')

cnt = -1
for id in ids:
    print(id)
    df[id] = 0
    cnt += 1
    filee = file[id].values

    for time in range(time_min, time_max):
        if filee[time - time_min] == 0:
            continue
        if filee[time - time_min + 15] == -1:
            break
        cur = time - origin['Unix time'].values[0]
        ans = solve(id, time)
        df.iloc[cur, cnt] = ans
        
tttmp = 'ques4_' + name
df.to_csv(tttmp)