from sklearn.linear_model import LinearRegression
import pandas as pd
import numpy as np

def decompose(a):
    ans = []
    while a >= 1:
        ans.append(int(a % 10))
        a = int(a / 10)
    return ans

def calc_b(y):
    reg = LinearRegression()
    len_ = len(y)
    y = y.reshape(-1, 1)
    x = [i for i in range(1, len_ + 1)]
    x = np.array(x)
    x = x.reshape(-1, 1)
    reg.fit(x, y)
    return reg.coef_, reg.score(x, y)

def calc_similarity(a, b):
    a_digits = decompose(a)
    b_digits = decompose(b)

    all_in_a = True

    for d in a_digits:
        if d not in b_digits:
            all_in_a = False
            break

    all_in_b = True

    for d in b_digits:
        if d not in a_digits:
            all_in_b = False
            break

    return all_in_a or all_in_b
    
def solve_3_1(data):
    start = 0
    while data[start] == 0:
        start += 1

    end = len(data)
    intervals = []
    sss = True

    while start < end - 1 and sss:
        cur = start
        flag = True
        while flag:
            if data[cur] == -1:
                sss = False
                break

            if data[cur + 1] == -1:
                sss = False
                break

            flag = calc_similarity(data[cur], data[cur + 1])
            cur += 1
        interval = str(start) + '-' + str(cur - 1)
        # print(interval)
        intervals.append(interval)
        start = cur

    return intervals