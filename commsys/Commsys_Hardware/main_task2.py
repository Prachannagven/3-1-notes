from plot_time import plot_time
from infosource import infosource
from spectrum_signal import spectrum_signal
from filter_sinc import filter_sinc
from convo_out import convo_out
import matplotlib.pyplot as plt
from rxdemod import rxdemod
import numpy as np
import random
from txmod import txmod
from scipy.io import wavfile
from adc import adc


def main():
    f = 5
    fs = 10*f
    for T in range(5):
        m_t, t = infosource("sine", f, fs, 10, T)
        max = np.max(m_t)
        min = np.min(m_t)
        x_t = adc(m_t, t, fs, 3, "PCM", max, min)
        print(x_t)

        
if __name__ == "__main__":
    main()
    input()
