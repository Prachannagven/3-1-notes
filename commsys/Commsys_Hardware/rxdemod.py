import numpy as np
import matplotlib.pyplot as plt
import random
from filter_sinc import filter_sinc
from convo_out import convo_out
from scipy.signal import find_peaks
from scipy.interpolate import CubicSpline

#Taking input as the message signal and the time it's ran over
def rxdemod(m_t, t, mod_type, f_c, f_m, fs, kf, **kwargs):
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
        dt = t[1] - t[0]


        d_m_dt = np.gradient(m_t, dt)
        peaks_indices, _ = find_peaks(d_m_dt)
        upper_envelope_interp = CubicSpline(t[peaks_indices], d_m_dt[peaks_indices])
        x_t = upper_envelope_interp(t) - 2*np.pi*f_c
        x_t = x_t/(kf*2*np.pi)
        x_t = x_t - np.mean(x_t)
        # analytic_signal = hilbert(m_t)
        # instantaneous_phase = np.unwrap(np.angle(analytic_signal))
        # instantaneous_frequency = np.diff(instantaneous_phase) / (2 * np.pi * (t[1] - t[0]))
        # instantaneous_frequency = instantaneous_frequency - np.mean(instantaneous_frequency)
        # x_t = np.concatenate(([instantaneous_frequency[0]], instantaneous_frequency))

    elif mod_type == "th detection":
         # Find positive peaks
        pos_peaks, _ = find_peaks(m_t)
        # Find negative peaks (by inverting the signal)
        neg_peaks, _ = find_peaks(-m_t)

        # Get the max positive peak value (if any)
        max_peak = m_t[pos_peaks].max() if len(pos_peaks) > 0 else 0
        # Get the most negative peak value (if any)
        min_peak = m_t[neg_peaks].min() if len(neg_peaks) > 0 else 0

        # Compare amplitudes
        if abs(max_peak) > abs(min_peak):
            x_t = 1   # Stronger positive peak → logic 1
        else:
            x_t = -1   # Stronger negative peak → logic 0

        x_t = [x_t] * len(t)
        x_t = np.array(x_t)


    return x_t