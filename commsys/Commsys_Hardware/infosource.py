import numpy as np
import matplotlib.pyplot as plt
import random
from scipy.io import wavfile
import sounddevice as sd

def infosource(signal_type,f,fs,amp,T):

    if signal_type == "sine":   
        start_time = 0
        stop_time = 1
        t = np.linspace((start_time+T), (stop_time+T), int(fs * (stop_time - start_time)) + 1)
        m_t = amp * np.sin(2 * np.pi * f * t)
             

    elif signal_type == 'multitone':
        f_1=f
        f_2 = 2 * f_1
        f_max = max(f_1, f_2)
        fs = 10 * f_max
        start_time = 0
        stop_time = 1
        A_1 = 1
        A_2 = 1
        t = np.linspace(start_time+T, stop_time+T, int(fs * (stop_time - start_time)) + 1)

        m_t = A_1 * np.sin(2 * np.pi * f_1 * t) + A_2 * np.sin(2 * np.pi * f_2 * t)
       
    elif signal_type == "sinc":
        
        start_time = -10
        stop_time = 10
        U = random.randint(1, 5)
        t = np.linspace(start_time+T, stop_time+T, int(fs * (stop_time - start_time)) + 1)
        m_t =  2 * U * f * np.sinc(2 * f* (t-T))
        

    elif signal_type == "real_time_song":
        fs, m_t = wavfile.read("waving.wav")
        ts = 1/fs
        print(fs)
        if m_t.ndim > 1:
            m_t = m_t[:, 0]
        m_t = m_t[T*fs:(T+1)*fs]

        t = np.arange(T, (T+1), ts)

    #350 Hz + 440 Hz signal addition
    elif signal_type == "dial_tone":
        start_time = 0
        A = 0.1
        stop_time = 1
        f1 = 350
        f2 = 440
        fs = 10 * max(f1, f2)
        t = np.linspace(start_time+T, stop_time+T, int(fs * (stop_time - start_time) + 1))
        m_t = A * (np.sin(2 * np.pi * f1 * t) + np.sin(2 * np.pi * f2 * t))

    #440 Hz + 480 Hz signal addition, 2 sec on, 4 sec off
    elif signal_type == "ringing_tone":
        start_time = 0
        stop_time = 1
        A = 0.1
        f1 = 350
        f2 = 440
        fs = 10 * max(f1, f2)
        ON, OFF = 2, 4
        t = np.linspace(start_time+T, stop_time+T, int(fs * (stop_time - start_time) + 1))
        tone = A * (np.sin(2 * np.pi * f1 * t) + np.sin(2 * np.pi * f2 * t))
        mask = ((t // 1) % (ON + OFF)) < ON
        m_t = tone * mask


    #480 Hz + 620 Hz signal addition, half second on, half second off
    elif signal_type == "busy_tone":
        start_time = 0
        stop_time = 1
        A = 0.1
        f1 = 350
        f2 = 440
        fs = 10 * max(f1, f2)
        ON, OFF = 0.5, 0.5
        t = np.linspace(start_time+T, stop_time+T, int(fs * (stop_time - start_time) + 1))
        m_t = A * (np.sin(2 * np.pi * f1 * t) + np.sin(2 * np.pi * f2 * t))

    elif signal_type == "idle":
        start_time = 0
        stop_time = 1
        A = 0
        t = np.linspace(start_time+T, stop_time+T, int(fs * (stop_time - start_time) + 1))
        m_t = 0 * t
              
    else:
        raise ValueError("Unsupported signal type: choose 'sine' or 'sinc'.")
    
    m_t = np.array(m_t, ndmin=2)
    t = np.array(t, ndmin=2)

    return m_t, t

def infosource_bits(signal_type):
    
    if signal_type == "charname":
        name = "PRANAV"
        bits = []
        for char in name:
            ascii_val = ord(char)
            bits_stream = bin(ascii_val)[2:].zfill(8)
            bits.extend([int(bit) for bit in bits_stream])

        t = np.linspace(0, len(bits)-1, len(bits))

    bits = np.array(bits)
    t = np.array(t)

    return bits, t
    