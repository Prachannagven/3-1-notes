import numpy as np


def adc(m_t, t, fs, N, adc_type, max, min):

    if adc_type == "PCM":
        #Quantizing
        x_t = (m_t/(max-min))*(pow(N, 2) - 1) + (pow(N, 2)/2)
        x_t = (np.round(x_t)).astype(np.int16)
        print(x_t)
        x_bin_t = []
        for num in x_t:
            x_bin_t = np.append(x_bin_t, format(str(bin(num))[2:], f"0{N}b"))

        x_t = x_bin_t


    elif adc_type == "DM":
        pass

    return x_t