"""Núcleo de DSP da Prática 5 - Filtros IIR (e WindowSinc para o item 5).
Todas as rotinas reproduzem fielmente o código MATLAB apresentado no relatório."""
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

# --------------------------------------------------------------------------
# Estilo "MATLAB" para todas as figuras
# --------------------------------------------------------------------------
MATLAB_BLUE = (0.0, 0.4470, 0.7410)
MATLAB_RED  = (0.8500, 0.3250, 0.0980)

def apply_matlab_style():
    plt.rcParams.update({
        "figure.facecolor": "#F0F0F0",      # janela cinza do MATLAB
        "axes.facecolor":   "white",
        "axes.edgecolor":   "#262626",
        "axes.linewidth":   0.8,
        "axes.grid":        False,
        "axes.titleweight": "bold",
        "axes.titlesize":   10,
        "axes.titlepad":    6.0,
        "axes.labelsize":   9,
        "axes.prop_cycle":  plt.cycler(color=[MATLAB_BLUE, MATLAB_RED]),
        "lines.linewidth":  0.7,
        "font.family":      "sans-serif",
        "font.size":        9,
        "xtick.direction":  "in",
        "ytick.direction":  "in",
        "xtick.top":        False,
        "ytick.right":      False,
        "savefig.facecolor":"#F0F0F0",
        "savefig.dpi":      150,
        "figure.autolayout": False,
    })

def style_ax(ax):
    """Caixa fechada nos 4 lados, como no MATLAB."""
    for s in ax.spines.values():
        s.set_visible(True)
    ax.tick_params(labelsize=8)

# --------------------------------------------------------------------------
# Item 1 - Filtros de pólo simples (R-C)
# --------------------------------------------------------------------------
def CalculaFPBIIR(fc, x):
    """Passa-baixas de pólo simples:  y[n] = a0 x[n] + b1 y[n-1]."""
    x = np.asarray(x, float)
    nx = len(x)
    r = np.exp(-2*np.pi*fc)
    a0 = 1 - r
    b1 = r
    y = np.zeros(nx)
    y[0] = a0*x[0]
    for i in range(1, nx):
        y[i] = a0*x[i] + b1*y[i-1]
    return y

def CalculaFPAIIR(fc, x):
    """Passa-altas de pólo simples: y[n] = a0 x[n] + a1 x[n-1] + b1 y[n-1]."""
    x = np.asarray(x, float)
    nx = len(x)
    r = np.exp(-2*np.pi*fc)
    a0 = (1 + r)/2
    a1 = -(1 + r)/2
    b1 = r
    y = np.zeros(nx)
    y[0] = a0*x[0]
    for i in range(1, nx):
        y[i] = a0*x[i] + a1*x[i-1] + b1*y[i-1]
    return y

# --------------------------------------------------------------------------
# Item 3 - Filtros recursivos de banda estreita (Smith, Eng. Guide to DSP)
# --------------------------------------------------------------------------
def FiltroPassaBanda(bw, f, x):
    x = np.asarray(x, float)
    nx = len(x)
    r = 1 - 3*bw
    k = (1 - 2*r*np.cos(2*np.pi*f) + r**2) / (2 - 2*np.cos(2*np.pi*f))
    a0 = 1 - k
    a1 = 2*(k - r)*np.cos(2*np.pi*f)
    a2 = r**2 - k
    b1 = 2*r*np.cos(2*np.pi*f)
    b2 = -r**2
    y = np.zeros(nx)
    y[0] = a0*x[0]
    y[1] = a0*x[1] + a1*x[0] + b1*y[0]
    for i in range(2, nx):
        y[i] = a0*x[i] + a1*x[i-1] + a2*x[i-2] + b1*y[i-1] + b2*y[i-2]
    return y

def FiltroRejeitaBanda(bw, f, x):
    x = np.asarray(x, float)
    nx = len(x)
    r = 1 - 3*bw
    k = (1 - 2*r*np.cos(2*np.pi*f) + r**2) / (2 - 2*np.cos(2*np.pi*f))
    a0 = k
    a1 = -2*k*np.cos(2*np.pi*f)
    a2 = k
    b1 = 2*r*np.cos(2*np.pi*f)
    b2 = -r**2
    y = np.zeros(nx)
    y[0] = a0*x[0]
    y[1] = a0*x[1] + a1*x[0] + b1*y[0]
    for i in range(2, nx):
        y[i] = a0*x[i] + a1*x[i-1] + a2*x[i-2] + b1*y[i-1] + b2*y[i-2]
    return y

# --------------------------------------------------------------------------
# WindowSinc passa-baixas (Prática 4) - usado no item 5
# --------------------------------------------------------------------------
def FWSPB(M, FC):
    """Filtro WindowSinc passa-baixas com janela de Blackman (M coef.)."""
    H = np.zeros(M)
    m2 = M/2
    for i in range(1, M+1):
        if (i - m2) == 0:
            H[i-1] = 2*np.pi*FC
        else:
            H[i-1] = np.sin(2*np.pi*FC*(i - m2)) / (i - m2)
        w = 0.42 - 0.5*np.cos(2*np.pi*i/M) + 0.08*np.cos(4*np.pi*i/M)
        H[i-1] *= w
    H = H / np.sum(H)
    return H

# --------------------------------------------------------------------------
# Utilidades
# --------------------------------------------------------------------------
def resposta_filtro(func, *args, M=100):
    """Resposta ao impulso (M pontos) e resposta em frequência."""
    imp = np.zeros(M); imp[0] = 1.0
    h = func(*args, imp)
    H = np.fft.fft(h)
    ganho = np.abs(H)
    aten = 20*np.log10(ganho + 1e-12)
    fase = np.angle(H)
    return h, ganho, aten, fase
