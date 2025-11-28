import matplotlib.pyplot as plt


def plot_time(t, m_t, title="", usr_label=""):
    plt.figure(1)
    plt.plot(t, m_t, label=usr_label)
    plt.title(title)
    plt.xlabel("Time")
    plt.ylabel("Signal Amplitude")
    plt.grid(True)
    plt.legend()