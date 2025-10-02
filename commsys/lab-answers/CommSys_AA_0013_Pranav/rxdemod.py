import numpy as np
import matplotlib.pyplot as plt
import random
from filter_sinc import filter_sinc
from convo_out import convo_out
from scipy.signal import find_peaks, hilbert
from scipy.interpolate import CubicSpline

#Taking input as the message signal and the time it's ran over
def rxdemod(m_t, t, mod_type, f_c, f_m, fs):
    #m_t = message signal
    #t   = time period over which signal is being observed
    #mod_type = the demodulation type used
    #f_c = carrier frequency that's being used
    #f_m = max frequency of the message signal

    #Synchronus demodulation of DSB-SC
    if mod_type == "SD":
        y_t = m_t * np.cos(2*np.pi*f_c*t)
        lpf = filter_sinc(f_m, 2*f_c)
        x_t = convo_out(y_t, lpf)*1/f_c

    #Envelope Detection
    elif mod_type == "ED":
        peaks_indices, _ = find_peaks(m_t)
        upper_envelope_interp = CubicSpline(t[peaks_indices], m_t[peaks_indices])
        x_t = upper_envelope_interp(t)

    elif mod_type == "EDFM":
        analytic_signal = hilbert(m_t)
        instantaneous_phase = np.unwrap(np.angle(analytic_signal))
        instantaneous_frequency = np.diff(instantaneous_phase) / (2 * np.pi * (t[1] - t[0]))
        instantaneous_frequency = instantaneous_frequency - np.mean(instantaneous_frequency)
        x_t = np.concatenate(([instantaneous_frequency[0]], instantaneous_frequency))

    return x_t