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


def main():
    plt.ion()
    all_m_t = []
    all_x_t = []
    all_m_t_demod = []
    all_t = []

    for T in range(15):
        amp=1
        f=10 #random.randint(5, 50)
        f_c = 50000    #increasing f_c moves the frequency bands further from the center. It just helps to convolve the frequency domain of the message
        fs=12*(f+f_c)

        #Making the main signal
        m_t,t = infosource("real_time_song",f,fs,amp,T)
        #t = np.linspace((T), (1+T), int(fs * (1)) + 1) 
        #m_t = 1 * np.sin(20 * np.pi * t)
        M_f = spectrum_signal(m_t, fs, 1, "black", lab="Main Signal")

        # Modulating the Signal
        x_t = txmod(m_t, t, "FM", f_c, k_f=0.5)
        #X_f = spectrum_signal(x_t, fs, 1, "green", lab="FM, kf = 5")

        # Demodulating the Signal
        m_t = rxdemod(x_t, t, "EDFM", f_c, f, fs)
        #M_f = spectrum_signal(m_t, fs, 1, "orange", lab="EDFM")

        all_m_t.append(m_t)
        all_x_t.append(x_t)
        all_m_t_demod.append(m_t)
        all_t.append(t)

    # Plot once after the loop
    fig, axs = plt.subplots(3, 2, figsize=(12, 10))
    # Row 1: Message
    for t, m in zip(all_t, all_m_t):
        axs[0, 0].plot(t, m, alpha=0.6)
    axs[0, 0].set_title('Message Signal (Time)')
    axs[0, 0].set_xlabel('Time (s)')
    axs[0, 0].set_ylabel('Amplitude')
    axs[0, 0].grid(True)
    for t, m in zip(all_t, all_m_t):
        freq1, M_f = spectrum_signal(m, fs, 0)
        axs[0, 1].plot(freq1, np.abs(M_f), alpha=0.6)
    axs[0, 1].set_title('Message Signal (Frequency)')
    axs[0, 1].set_xlabel('Frequency (Hz)')
    axs[0, 1].set_ylabel('Magnitude')
    axs[0, 1].grid(True)

    # Row 2: Modulated
    for t, x in zip(all_t, all_x_t):
        axs[1, 0].plot(t, x, alpha=0.6)
    axs[1, 0].set_title('FM Modulated Signal (Time)')
    axs[1, 0].set_xlabel('Time (s)')
    axs[1, 0].set_ylabel('Amplitude')
    axs[1, 0].grid(True)
    for t, x in zip(all_t, all_x_t):
        freq2, X_f = spectrum_signal(x, fs, 0)
        axs[1, 1].plot(freq2, np.abs(X_f), alpha=0.6)
    axs[1, 1].set_title('FM Modulated Signal (Frequency)')
    axs[1, 1].set_xlabel('Frequency (Hz)')
    axs[1, 1].set_ylabel('Magnitude')
    axs[1, 1].grid(True)

    # Row 3: Demodulated
    for t, m in zip(all_t, all_m_t_demod):
        axs[2, 0].plot(t, m, alpha=0.6)
    axs[2, 0].set_title('Demodulated Signal (Time)')
    axs[2, 0].set_xlabel('Time (s)')
    axs[2, 0].set_ylabel('Amplitude')
    axs[2, 0].grid(True)
    for t, m in zip(all_t, all_m_t_demod):
        freq3, M_f_demod = spectrum_signal(m, fs, 0)
        axs[2, 1].plot(freq3, np.abs(M_f_demod), alpha=0.6)
    axs[2, 1].set_title('Demodulated Signal (Frequency)')
    axs[2, 1].set_xlabel('Frequency (Hz)')
    axs[2, 1].set_ylabel('Magnitude')
    axs[2, 1].grid(True)

    plt.tight_layout()
    plt.show()
        
if __name__ == "__main__":
    main()
    input()
