# -*- coding: utf-8 -*-
"""
Pratica 4 - Filtros Window-sinc (FIR)
Replica em Python (numpy) exatamente as rotinas MATLAB do relatorio e
gera todas as figuras usadas no PDF.
"""
import os
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import scipy.io as sio

FIG = os.path.join(os.path.dirname(os.path.abspath(__file__)), "figs")
os.makedirs(FIG, exist_ok=True)
MAT = "/mnt/c/Users/sergio.maccari_driva/Documents/pratica 4 ASL/ImagemHibrida1s2025.mat"

plt.rcParams.update({
    "figure.dpi": 150,
    "savefig.dpi": 150,
    "axes.grid": True,
    "grid.alpha": 0.35,
    "font.size": 10,
})

# ----------------------------------------------------------------------
# Rotinas dos filtros (espelham o codigo MATLAB do relatorio)
# ----------------------------------------------------------------------
def fwspb(M, FC, janela=True):
    """Filtro Window-sinc passa-baixas com janela de Blackman."""
    H = np.zeros(M + 1)
    m2 = M / 2.0
    for i in range(M + 1):
        if (i - m2) == 0:
            H[i] = 2 * np.pi * FC
        else:
            H[i] = np.sin(2 * np.pi * FC * (i - m2)) / (i - m2)
        if janela:                                  # janela de Blackman
            w = 0.42 - 0.5 * np.cos(2 * np.pi * i / M) + 0.08 * np.cos(4 * np.pi * i / M)
            H[i] = H[i] * w
    H = H / np.sum(H)                               # ganho unitario em DC
    return H

def fwspa(M, FC):
    """Passa-altas por inversao espectral do passa-baixas (com janela)."""
    H = fwspb(M, FC, janela=True)
    H = -H
    H[int(M / 2)] = H[int(M / 2)] + 1
    return H

# ----------------------------------------------------------------------
# Helpers de plotagem
# ----------------------------------------------------------------------
def resp_freq(h, Nfft=8192):
    Hf = np.fft.fft(h, Nfft)
    f = np.arange(Nfft) / Nfft
    half = Nfft // 2
    return f[:half], np.abs(Hf[:half])

def salva(nome):
    plt.tight_layout()
    plt.savefig(os.path.join(FIG, nome), bbox_inches="tight")
    plt.close()

def plot_tempo(h, titulo, nome):
    plt.figure(figsize=(7, 3.0))
    plt.plot(np.arange(len(h)), h, color="#1f6fb4", lw=1.1)
    plt.title(titulo)
    plt.xlabel("n (amostras)")
    plt.ylabel("h[n]")
    salva(nome)

def plot_freq(h, titulo, nome, fc_marcas=None):
    f, mag = resp_freq(h)
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(7, 4.8))
    ax1.plot(f, mag, color="#1f6fb4", lw=1.2)
    ax1.set_title(titulo + "  —  Ganho (linear)")
    ax1.set_xlabel("Frequência normalizada (ciclos/amostra)")
    ax1.set_ylabel("Ganho |H(f)|")
    ax1.set_xlim(0, 0.5)
    db = 20 * np.log10(np.maximum(mag, 1e-9))
    ax2.plot(f, db, color="#b22222", lw=1.2)
    ax2.set_title("Atenuação (dB)")
    ax2.set_xlabel("Frequência normalizada (ciclos/amostra)")
    ax2.set_ylabel("|H(f)| (dB)")
    ax2.set_xlim(0, 0.5)
    ax2.set_ylim(-120, 10)
    if fc_marcas:
        for fc in fc_marcas:
            ax1.axvline(fc, color="gray", ls="--", lw=0.8)
            ax2.axvline(fc, color="gray", ls="--", lw=0.8)
    salva(nome)

def plot_sinal(y, titulo, nome, cor="#1f6fb4"):
    plt.figure(figsize=(7, 3.0))
    plt.plot(np.arange(len(y)), y, color=cor, lw=0.6)
    plt.title(titulo)
    plt.xlabel("n (amostras)")
    plt.ylabel("Amplitude")
    salva(nome)

def plot_espectro(y, titulo, nome, picos=None):
    Y = np.abs(np.fft.fft(y))
    k = np.arange(len(Y))
    plt.figure(figsize=(7, 3.0))
    plt.plot(k, Y, color="#1f6fb4", lw=0.8)
    plt.title(titulo)
    plt.xlabel("Índice de frequência k (bins da FFT)")
    plt.ylabel("|FFT|")
    plt.xlim(0, len(Y))
    if picos:
        for p in picos:
            plt.axvline(p, color="gray", ls="--", lw=0.7)
    salva(nome)

def picos_fft(y, altura_rel=0.25):
    """Retorna os bins de pico (na metade inferior do espectro)."""
    Y = np.abs(np.fft.fft(y))
    N = len(Y)
    th = altura_rel * Y.max()
    picos = []
    for k in range(1, N // 2):
        if Y[k] > th and Y[k] >= Y[k - 1] and Y[k] >= Y[k + 1]:
            picos.append(k)
    return picos

resumo = []

# ======================================================================
# ITEM 2a) FPB com janela de Blackman, FC=0.15, M=100
# ======================================================================
FC, M = 0.15, 100
fpb = fwspb(M, FC, janela=True)
plot_tempo(fpb, "Resposta ao impulso do FPB (FC=0,15  M=100)", "fig_2a_tempo.png")
plot_freq(fpb, "FPB com janela de Blackman", "fig_2a_freq.png", fc_marcas=[FC])
resumo.append("2a) FPB Blackman: atenuacao minima na banda de rejeicao = %.1f dB"
              % (20*np.log10(resp_freq(fpb)[1][resp_freq(fpb)[0] > 0.25].max())))

# ======================================================================
# ITEM 2b) FPB SEM janela -> ripple (Gibbs)
# ======================================================================
fpb_sj = fwspb(M, FC, janela=False)
plot_tempo(fpb_sj, "Resposta ao impulso do FPB SEM janela (FC=0,15  M=100)", "fig_2b_tempo.png")
plot_freq(fpb_sj, "FPB sem janela (janela retangular)", "fig_2b_freq.png", fc_marcas=[FC])
f_sj, m_sj = resp_freq(fpb_sj)
ripple_pb = m_sj[f_sj < 0.10].max() - m_sj[f_sj < 0.10].min()
resumo.append("2b) FPB sem janela: ripple pico-a-pico na banda de passagem = %.4f ; "
              "1o lobo lateral ~ %.1f dB"
              % (ripple_pb, 20*np.log10(m_sj[f_sj > 0.20].max())))

# ======================================================================
# ITEM 3) FPA (passa-altas) por inversao espectral, FC=0.15, M=100
# ======================================================================
fpa = fwspa(M, FC)
plot_tempo(fpa, "Resposta ao impulso do FPA (FC=0,15  M=100)", "fig_3_tempo.png")
plot_freq(fpa, "FPA por inversão espectral (Blackman)", "fig_3_freq.png", fc_marcas=[FC])

# ======================================================================
# ITEM 4) FPF (passa-faixa) e FCF (corta-faixa), fc=0.15 e 0.30, 100 pontos
# ======================================================================
fci, fcs = 0.15, 0.30
# Passa-faixa: convolucao de LP(0.30) com HP(0.15)  -> 51+51-1 = 101 taps
fpf = np.convolve(fwspb(50, fcs), fwspa(50, fci))
# Corta-faixa: soma de LP(0.15) com HP(0.30)        -> 101 taps
fcf = fwspb(100, fci) + fwspa(100, fcs)
resumo.append("4) FPF len=%d  FCF len=%d (ambos 100 pontos / 101 taps)"
              % (len(fpf), len(fcf)))
plot_tempo(fpf, "Resposta ao impulso do FPF (passa-faixa 0,15–0,30)", "fig_4_fpf_tempo.png")
plot_freq(fpf, "FPF passa-faixa (0,15–0,30)", "fig_4_fpf_freq.png", fc_marcas=[fci, fcs])
plot_tempo(fcf, "Resposta ao impulso do FCF (corta-faixa 0,15–0,30)", "fig_4_fcf_tempo.png")
plot_freq(fcf, "FCF corta-faixa (0,15–0,30)", "fig_4_fcf_freq.png", fc_marcas=[fci, fcs])

# ======================================================================
# ITEM 5) Sinal x(n) e filtragens
# ======================================================================
n = np.arange(1, 1001)
x = (np.sin(np.pi*100*n/1000) + np.sin(np.pi*500*n/1000) + np.sin(np.pi*800*n/1000))
plot_sinal(x, "Sinal x(n) = soma de 3 senoides (1000 amostras)", "fig_5_x_tempo.png")
plot_espectro(x, "Espectro de x(n)  |FFT|", "fig_5_x_freq.png", picos=picos_fft(x))
resumo.append("5) picos de x(n) (bins) = %s" % picos_fft(x))

filtros = [("pb", fpb, "FPB (passa-baixas)"),
           ("pa", fpa, "FPA (passa-altas)"),
           ("pf", fpf, "FPF (passa-faixa)"),
           ("cf", fcf, "FCF (corta-faixa)")]
for tag, h, nome in filtros:
    y = np.convolve(x, h)
    plot_sinal(y, "x(n) filtrado pelo %s — tempo" % nome, "fig_5_%s_tempo.png" % tag)
    plot_espectro(y, "x(n) filtrado pelo %s — |FFT|" % nome, "fig_5_%s_freq.png" % tag,
                  picos=picos_fft(y))
    resumo.append("5) %s: picos filtrados (bins) = %s" % (tag, picos_fft(y)))

# ======================================================================
# ITEM 6) verificacao do deslocamento das raias  f_conv = f0*(N+M)/N
# ======================================================================
N, Mf = 1000, 100
for f0 in [50, 250, 400]:
    resumo.append("6) raia %d Hz -> %.0f bins apos conv (N=%d,M=%d)"
                  % (f0, f0*(N+Mf)/N, N, Mf))

# ======================================================================
# ITEM 7) Imagem hibrida Marilyn (PB) / Einstein (PA)
# ======================================================================
d = sio.loadmat(MAT)
IH = d["Imagem_hibrida"].astype(float)
rows, cols = IH.shape
resumo.append("7) imagem shape = %s  min=%.1f max=%.1f" % (IH.shape, IH.min(), IH.max()))

def filtra_imagem(IH, kernel):
    rows, cols = IH.shape
    out = np.zeros((rows, cols + len(kernel) - 1))
    for i in range(rows):
        out[i, :] = np.convolve(IH[i, :], kernel)   # convolucao 'full' (como o enunciado)
    # recorta a regiao central ('same'): descarta as M/2 amostras de transiente
    # de cada borda, devolvendo a imagem com o tamanho original.
    ini = (len(kernel) - 1) // 2
    return out[:, ini:ini + cols]

def mostra_imagem(img, titulo, nome):
    lo, hi = np.percentile(img, [1, 99])           # contraste robusto (evita outliers)
    plt.figure(figsize=(5.0, 5.4))
    plt.imshow(img, cmap="gray", vmin=lo, vmax=hi, aspect="auto")
    plt.title(titulo)
    plt.axis("off")
    salva(nome)

mostra_imagem(IH, "Imagem híbrida original", "fig_7_original.png")

# parametros escolhidos (justificados no relatorio)
fc_img, M_img = 0.05, 60
ws_pb = fwspb(M_img, fc_img, janela=True)
ws_pa = fwspa(M_img, fc_img)
img_pb = filtra_imagem(IH, ws_pb)   # baixas frequencias -> Marilyn
img_pa = filtra_imagem(IH, ws_pa)   # altas frequencias  -> Einstein
mostra_imagem(img_pb, "Imagem filtrada com FPB (Marilyn / baixas freq.)", "fig_7_marilyn.png")
mostra_imagem(img_pa, "Imagem filtrada com FPA (Einstein / altas freq.)", "fig_7_einstein.png")

# Montagem para justificar a escolha de fc (varredura): sub-corte / ideal / sobre-corte
escolhas = [0.03, 0.05, 0.10]
fig, axs = plt.subplots(2, 3, figsize=(8.0, 6.4))
for j, fc_t in enumerate(escolhas):
    ip = filtra_imagem(IH, fwspb(M_img, fc_t, True))
    ia = filtra_imagem(IH, fwspa(M_img, fc_t))
    lp, hp = np.percentile(ip, [1, 99]); la, ha = np.percentile(ia, [1, 99])
    axs[0, j].imshow(ip, cmap="gray", vmin=lp, vmax=hp, aspect="auto")
    axs[0, j].set_title("FPB  fc=%.2f" % fc_t, fontsize=10)
    axs[1, j].imshow(ia, cmap="gray", vmin=la, vmax=ha, aspect="auto")
    axs[1, j].set_title("FPA  fc=%.2f" % fc_t, fontsize=10)
    axs[0, j].axis("off"); axs[1, j].axis("off")
axs[0, 0].set_ylabel("Marilyn (PB)")
salva("fig_7_escolha.png")

print("\n".join(resumo))
print("OK - figuras geradas em", FIG)
