# convo_out.py (placeholder)
import numpy as np
import matplotlib.pyplot as plt
def convo_out(m_t,g_t):
    x_t=np.convolve(m_t,g_t,'same')
    return x_t