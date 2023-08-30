import numpy as np
import math

def pix2ang(pxl, d, pxlSize):
    deg = 2 * (180 / np.pi) * math.atan((pxlSize * pxl) / (d * 2))
    return deg