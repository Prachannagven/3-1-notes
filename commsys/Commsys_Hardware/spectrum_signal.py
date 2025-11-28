import numpy as np
import matplotlib.pyplot as plt

def spectrum_signal(m_t, fs, plt_on=1, col="", lab = ""):
    
    M_f = np.fft.fft(m_t)
    M_f_arrange=np.fft.fftshift(M_f)
    freq_axis =np.linspace(-fs/2, fs/2, len(M_f))

    if(plt_on):
        # Plot magnitude spectrum (linear scale)
        plt.figure(2)
        plt.plot(freq_axis, np.abs(M_f_arrange), color = col, label = lab)
        plt.title("Spectrum")
        plt.xlabel("Frequency (Hz)")
        plt.ylabel("|M(f)|")
        plt.grid(True)
        plt.tight_layout()
        plt.legend()
        plt.show()
        #plt.show(block=False)
    return freq_axis, M_f_arrange
