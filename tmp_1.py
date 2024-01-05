from sklearn.linear_model import LinearRegression
import pandas as pd
import numpy as np

def decompose(a): # 将一个整数分解为各个位上的数字：123 -> [3, 2, 1]
    ans = []
    while a >= 1:
        ans.append(int(a % 10))
        a = int(a / 10)
    return ans

def calc_b(y): 
    # R^2检验，返回值包括拟合斜率和线性拟合度，线性拟合度大于0.95则认为是线性关系，此时滑动窗口的长度不需要再减小
    reg = LinearRegression()
    len_ = len(y)
    y = y.reshape(-1, 1)
    x = [i for i in range(1, len_ + 1)]
    x = np.array(x)
    x = x.reshape(-1, 1)
    reg.fit(x, y)
    return reg.coef_, reg.score(x, y)

def calc_similarity(a, b):
    # 判断两个整数的各个位上的数字是否相同
    a_digits = decompose(a)
    b_digits = decompose(b)

    all_in_a = True # a中的数字是否都在b中

    for d in a_digits:
        if d not in b_digits:
            all_in_a = False
            break

    all_in_b = True # b中的数字是否都在a中

    for d in b_digits:
        if d not in a_digits:
            all_in_b = False
            break

    return all_in_a or all_in_b # Ture表示其中一个整数的各个位上的数字都在另一个整数中
    
def solve_3_1(data):# 对基本动作序列进行划分，每一段组成一个复杂动作
    start = 0
    while data[start] == 0:
        start += 1 # 找到第一个不为0的位置

    end = len(data)
    intervals = []
    sss = True

    while start < end - 1 and sss:
        cur = start
        flag = True
        while flag:
            if data[cur] == -1: # 到达基本序列的末尾（-1用作动作序列末尾的占位，也表示坠毁、降落）
                sss = False
                break

            if data[cur + 1] == -1:
                sss = False
                break

            flag = calc_similarity(data[cur], data[cur + 1]) 
            # Ture代表两个时刻的基本动作未发生突变，即只出现基本动作的增加或减少:123->12，而没有基本动作的改变:12->23
            cur += 1 # 切片长度加1直至基本动作发生突变

        interval = str(start) + '-' + str(cur - 1)
        # print(interval)
        intervals.append(interval) # 保存本次划分的动作片段位置
        start = cur

    return intervals