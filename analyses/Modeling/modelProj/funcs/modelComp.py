import numpy as np

def AICMet(MLL, paramNum):
    return (2 * paramNum) - (2 * (-1 * MLL))

def BICMet(MLL, paramNum, N):
    return (paramNum * np.log(N)) - (2 * (-1 * MLL))
