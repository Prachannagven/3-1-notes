import numpy as np
import matplotlib.pyplot as plt
import random
from plot_time import plot_time
from scipy.signal import hilbert    
from convo_out import convo_out
from spectrum_signal import spectrum_signal


#Taking input as the message signal and the time it's ran over
def txmod(m_t, t, mod_type, f_c, fs, k_f=0, mu=1, **kwargs):
    #The signal will be modulated according to the mod_type variable provided
    if mod_type == "DSB-SC":
        x_t = m_t * np.cos(2*np.pi*f_c*t)

    elif mod_type == "FM":
        x_t = (m_t + (np.max(m_t)/mu)) * np.cos(2*np.pi*f_c*t) 

    elif mod_type == "USSB":
        #Getting the hilbert message
        #m_th = convo_out(m_t, (1/(np.pi*(t+1e-8))))*1e-8
        freq, X_f = spectrum_signal(m_t, 1000, 0)
        X_f = X_f * 1j * np.sign(freq)
        m_th = np.fft.ifft(X_f)
        x_t = m_t*np.cos(2*np.pi*f_c*t) - m_th*np.sin(2*np.pi*f_c*t)

    elif mod_type == "LSSB":
        #Getting the hilbert message
        freq, X_f = spectrum_signal(m_t, 1000, 0)
        X_f = X_f * 1j * np.sign(freq)
        m_th = np.fft.ifft(X_f)
        x_t = m_t*np.cos(2*np.pi*f_c*t) + m_th*np.sin(2*np.pi*f_c*t)

    elif mod_type == "FM":
        integral_m_t = np.cumsum(m_t) / fs
        x_t = np.cos(2 * np.pi * f_c * t + 2 * np.pi * k_f * integral_m_t)   

    elif mod_type == "Polar":
        Rs = kwargs.get("Rs")
        B = Rs/2
        x_t = []
        t = np.linspace(-0.5, 0.5, fs)
        pos_rect = [0] * t
        neg_rect = [0] * t
        for i in range(len(t)):
            pos_rect[i] = 1
            neg_rect[i] = -1
        pos_sinc =  2 * B * np.sinc(2 * B * t)
        neg_sinc =  -2 * B * np.sinc(2 * B * t)
        if m_t: x_t = pos_rect
        else  : x_t = neg_rect

    elif mod_type == "2ARY-PAM":
        if(m_t): x_t = 5
        else: x_t = -5
    
    x_t = np.array(x_t)

    return x_t