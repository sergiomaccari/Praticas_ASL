"""Gera todas as figuras (estilo MATLAB) e os sinais recuperados da Prática 5."""
import numpy as np, scipy.io as sio
from scipy.io import wavfile
import matplotlib.pyplot as plt
import dsp_p5 as d

d.apply_matlab_style()
import os
BASE = os.path.dirname(os.path.abspath(__file__))
FIG  = BASE + "/figs/"
Fs_audio = 40000.0

# ============================ PARÂMETROS ESCOLHIDOS ========================
# Itens 1-2 (pólo simples)
FC_FPB = 0.10
FC_FPA = 0.10
fs12   = 1000.0          # Fs didático
f_low  = 30.0            # baixa frequência
f_high = 350.0           # alta frequência
# Itens 3-4 (banda estreita)
FC_BANDA = 0.25
BW_BANDA = 0.008
fs34   = 1000.0
tones4 = [40, 120, 250, 380, 470]
# Item 5 (som)
FC_LP5  = 0.075
M_WS5   = 100
F_NOTCH = 0.01915
BW_NOTCH= 0.0008
N_CASC  = 3

def save(fig, name):
    fig.tight_layout(); fig.savefig(FIG+name); plt.close(fig)
    print("  ", name)

def fig_resposta(h, ganho, aten, fase, titulo, fname):
    """2x2: resposta ao impulso, ganho, atenuação(dB), fase."""
    M = len(h); k = np.arange(M)
    fig, ax = plt.subplots(2, 2, figsize=(9, 5.2))
    ax[0,0].plot(k, h);     ax[0,0].set_title(f"{titulo} - resposta ao impulso h[n]")
    ax[0,1].plot(k, ganho); ax[0,1].set_title(f"{titulo} - ganho")
    ax[1,0].plot(k, aten);  ax[1,0].set_title(f"{titulo} - atenuação (dB)")
    ax[1,1].plot(k, fase);  ax[1,1].set_title(f"{titulo} - fase (rad)")
    for a in ax.flat: d.style_ax(a); a.set_xlim(0, M-1); a.set_xlabel("bin / amostra")
    save(fig, fname)

def fig_sinal_2x3(rows, titulo_rows, fname, fs):
    """3 linhas (sinais) x 2 colunas (tempo, |FFT|)."""
    fig, ax = plt.subplots(3, 2, figsize=(10, 7))
    for r, (sig, tit) in enumerate(zip(rows, titulo_rows)):
        Nn = len(sig); kk = np.arange(Nn)
        ax[r,0].plot(kk, sig);                 ax[r,0].set_title(f"{tit} - tempo")
        ax[r,1].plot(kk, np.abs(np.fft.fft(sig))); ax[r,1].set_title(f"{tit} - |FFT|")
        ax[r,0].set_xlim(0, Nn-1); ax[r,1].set_xlim(0, Nn-1)
    for a in ax.flat: d.style_ax(a)
    save(fig, fname)

def fig_tf(sig, titulo, fname, full_fft=True):
    """1x2: tempo e |FFT| (índice de amostra), para os sinais longos do item 5."""
    N = len(sig); k = np.arange(N)
    fig, ax = plt.subplots(1, 2, figsize=(10, 3.2))
    ax[0].plot(k, sig);                      ax[0].set_title(f"{titulo} - tempo")
    ax[1].plot(k, np.abs(np.fft.fft(sig)));  ax[1].set_title(f"{titulo} - |FFT|")
    for a in ax: d.style_ax(a); a.set_xlim(0, N-1); a.set_xlabel("amostra")
    save(fig, fname)

print("ITEM 1 - pólo simples")
h,g,a,p = d.resposta_filtro(d.CalculaFPBIIR, FC_FPB, M=100)
fig_resposta(h,g,a,p, f"FPB (fc={FC_FPB})", "f1_fpb.png")
h,g,a,p = d.resposta_filtro(d.CalculaFPAIIR, FC_FPA, M=100)
fig_resposta(h,g,a,p, f"FPA (fc={FC_FPA})", "f1_fpa.png")

print("ITEM 2 - teste FPB/FPA")
n12 = np.arange(1000)
x12 = np.sin(2*np.pi*f_low*n12/fs12) + np.sin(2*np.pi*f_high*n12/fs12)
y_fpb = d.CalculaFPBIIR(FC_FPB, x12)
y_fpa = d.CalculaFPAIIR(FC_FPA, x12)
fig_sinal_2x3([x12, y_fpb, y_fpa],
              ["Sinal gerado (30 + 350 Hz)", "Filtrado FPB", "Filtrado FPA"],
              "f2_teste.png", fs12)

print("ITEM 3 - banda estreita")
h,g,a,p = d.resposta_filtro(d.FiltroPassaBanda, BW_BANDA, FC_BANDA, M=100)
fig_resposta(h,g,a,p, f"Passa-banda (fc={FC_BANDA}, BW={BW_BANDA})", "f3_bp.png")
h,g,a,p = d.resposta_filtro(d.FiltroRejeitaBanda, BW_BANDA, FC_BANDA, M=100)
fig_resposta(h,g,a,p, f"Rejeita-banda (fc={FC_BANDA}, BW={BW_BANDA})", "f3_br.png")

print("ITEM 4 - teste banda estreita")
n34 = np.arange(1000)
x34 = sum(np.sin(2*np.pi*ft*n34/fs34) for ft in tones4)
y_bp = d.FiltroPassaBanda(BW_BANDA, FC_BANDA, x34)
y_br = d.FiltroRejeitaBanda(BW_BANDA, FC_BANDA, x34)
fig_sinal_2x3([x34, y_bp, y_br],
              [f"Sinal gerado {tones4} Hz", "Filtrado passa-banda (250 Hz)", "Filtrado rejeita-banda (250 Hz)"],
              "f4_teste.png", fs34)

print("ITEM 5 - processamento de som")
s = np.asarray(sio.loadmat(BASE+"/SinalRuidoModulado1s2026.mat")["sinalModulado"], float).squeeze()
N = len(s); n = np.arange(N)
# (a) sinal modulado
fig_tf(s, "Sinal ruído modulado", "f5_modulado.png")
# (b) demodulação
demod = s*np.cos(np.pi*n)
fig_tf(demod, "Sinal demodulado  x cos(pi n)", "f5_demodulado.png")
# (c) passa-baixas WindowSinc
h_ws = d.FWSPB(M_WS5, FC_LP5)
lp = np.convolve(demod, h_ws)[M_WS5//2 : M_WS5//2 + N]
fig_tf(lp, "Após passa-baixas WindowSinc", "f5_passabaixas.png")
# (d) rejeita-banda x3 (tom em ~766 Hz)
rb = lp.copy()
for _ in range(N_CASC):
    rb = d.FiltroRejeitaBanda(BW_NOTCH, F_NOTCH, rb)
fig_tf(rb, "Áudio recuperado (após rejeita-banda x3)", "f5_final.png")

# (e) zoom do tom antes/depois do notch
f = np.arange(N)*Fs_audio/N; lim = int(2000*N/Fs_audio)
fig, ax = plt.subplots(1, 1, figsize=(7, 3))
ax.plot(f[:lim], np.abs(np.fft.fft(lp))[:lim], label="após passa-baixas")
ax.plot(f[:lim], np.abs(np.fft.fft(rb))[:lim], color=d.MATLAB_RED, label="após rejeita-banda x3")
ax.set_title("Tom interferente em ~766 Hz - antes e depois do notch")
ax.set_xlabel("Hz"); ax.legend(fontsize=8); d.style_ax(ax)
save(fig, "f5_notch.png")

# (f) espectrograma do áudio recuperado
fig, ax = plt.subplots(1, 1, figsize=(8, 3.2))
ax.specgram(rb, NFFT=2048, Fs=Fs_audio, noverlap=1024, cmap="jet")
ax.set_ylim(0, 5000); ax.set_title("Espectrograma do áudio recuperado")
ax.set_xlabel("tempo (s)"); ax.set_ylabel("Hz"); d.style_ax(ax)
save(fig, "f5_espectrograma.png")

# ---- salva sinais recuperados ----
rec = rb / np.max(np.abs(rb)) * 0.95
sio.savemat(BASE+"/sinal_recuperado.mat",
            {"sinal_recuperado": rec.reshape(1, -1)})
wavfile.write(BASE+"/sinal_recuperado.wav", int(Fs_audio),
              (rec*32767).astype(np.int16))
print("salvos: sinal_recuperado.mat / .wav")
print("DONE")
