from plot_time import plot_time
from infosource import infosource, infosource_bits
from spectrum_signal import spectrum_signal
from filter_sinc import filter_sinc
from convo_out import convo_out
import matplotlib.pyplot as plt
from rxdemod import rxdemod
import numpy as np
import random
from txmod import txmod
from scipy.io import wavfile
from addawgn import addawgn



def main():
    plt.ion()
    bitstream, t = infosource_bits("charname")

    all_xt = np.empty((1))
    all_yt = np.empty((1))
    all_ot = []
    all_ot = np.array(all_ot)

    for T in range(len(bitstream)):
        amp=1
        f=10 #random.randint(5, 50)
        f_c = 50    #increasing f_c moves the frequency bands further from the center. It just helps to convolve the frequency domain of the message
        fs=2*(f+f_c)
        k_f = 100
        mu = 0
        var = 7

        x_t = txmod(bitstream.T[T], t[T], "2ARY-PAM", f_c, fs, Rs = 10)
        x_t = addawgn(x_t, t, 0, 5)
        all_xt = np.append(all_xt, x_t)
        '''
        x_t = txmod(bitstream.T[T], t[T], "Polar", f_c, fs, Rs = 10)
        all_xt = np.hstack((all_xt, x_t))
        t_transmission = np.linspace(t[T], (t[T]+1), fs).reshape(-1, 1)
      
        y_t = addawgn(x_t, t_transmission, mu, var)
        all_yt = np.hstack((all_yt, y_t))

        f_t = txmod(1, 0, "Polar", f_c, fs, Rs=10)
        y_t = convo_out(y_t, f_t)

        o_t = rxdemod(y_t, t_transmission, "th detection", f_c, f, fs, k_f)
        out_t = o_t[::fs] # One element per bit
        all_ot = np.append(all_ot, out_t)

        plt.plot(t_transmission, y_t.T, color='red')
        plt.plot(t_transmission, x_t.T, color='blue')
        plt.plot(t_transmission, o_t.T, color='green')
        #plt.pause(0.1)

    for i in range(len(all_ot)):
        if(all_ot[i]) == -1:
            all_ot[i] = 0

    err_bits_count = np.sum(all_ot != bitstream)
    bit_error_rate = err_bits_count / bitstream.size

    print("Bitstream Shape: ", bitstream.shape)
    print("Time Shape: ", t.shape)
    print("Number of Bad Bits: ", err_bits_count)
    print("Total Number of Bits: ", bitstream.size)
    print("Bit Error Rate: ", bit_error_rate)
    '''
    print(all_xt)
    plt.scatter(all_xt, np.imag(all_xt))
    



if __name__ == "__main__":
    main()
    input()
