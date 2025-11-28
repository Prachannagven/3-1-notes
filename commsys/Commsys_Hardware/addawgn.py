import numpy as np
import matplotlib.pyplot as plt
import random
from scipy.io import wavfile
import sounddevice as sd


def addawgn(m_t, t, mu, var):
    noise = np.sqrt(var) * np.random.randn(m_t.size) + mu  #Accounting for the mu and var provided and making sure it's the same dim as m_t
    y_t = m_t + noise
    return y_t