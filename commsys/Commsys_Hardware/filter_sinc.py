
import numpy as np
import matplotlib.pyplot as plt
def filter_sinc(B, fs):
    amplitude = 1
    start_time = -1
    stop_time=1
    t = np.linspace(start_time, stop_time, int(fs * (stop_time-start_time)) + 1)
    g_t =  2 * B * np.sinc(2 * B * t)
    
    return g_t