import numpy as np
import matplotlib.pyplot as plt
from scipy.io import wavfile
import sounddevice as sd
# Load WAV
fs, m_T = wavfile.read("waving.wav")

# If stereo, take one channel
if m_T.ndim > 1:
    m_T = m_T[:, 0]

# Convert to float in [-1,1] for nicer plotting (handles int16, etc.)
#x = x.astype(np.float32)
#if np.max(np.abs(x)) > 0:
    #x = x / np.max(np.abs(x))

# ---- 1) Plot the entire waveform ----
t = np.arange(len(m_T)) /fs
plt.figure(1)
plt.plot(t, m_T, linewidth=0.8)
plt.xlabel("Time (s)")
plt.ylabel("Amplitude (norm.)")
plt.title("waving.wav — Time Domain")
plt.tight_layout()
plt.show()

# ---- 2) (Optional) Process & plot per second using m_T ----
duration = int(len(m_T) /fs)
for T in range(duration):
    start = T *fs
    end = (T + 1) * fs
    m_t = m_T[start:end]  # your per-second segment

    # Example plot for each second:
    t_T = np.arange(len(m_t)) /fs + T  # time axis aligned to absolute time
    plt.figure(2)
    plt.plot(t_T,m_t, linewidth=0.8)
    plt.xlabel("Time (s)")
    plt.ylabel("Amplitude (norm.)")
    plt.title(f"Time Domain (T = {T} s)")
    plt.tight_layout()
    plt.show(block=False)
    plt.pause(0.2)
    sd.play(m_t, fs)
    sd.wait() 
    mf = np.fft.fft(m_t) / fs
    N = len(mf)
    mf_abs_sorted = np.fft.fftshift(abs(mf))
    freq_axis = np.linspace(-fs / 2, fs / 2, N)
    plt.figure(3)
    plt.plot(freq_axis, 10 * np.log10(mf_abs_sorted))
    #plt.title(f'Frequency Domain, Time=({start_time + T}, {stop_time + T})')
    plt.xlabel('Frequency (Hz)')
    plt.ylabel('Magnitude')
    plt.show(block=False)

