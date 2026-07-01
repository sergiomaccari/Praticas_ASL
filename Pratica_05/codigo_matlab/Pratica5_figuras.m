%% ========================================================================
%  Pratica 5 - Filtros IIR  --  Geracao das figuras do relatorio (MATLAB)
%  Usa as rotinas da pratica (CalculaFPBIIR, CalculaFPAIIR, FiltroPassaBanda,
%  FiltroRejeitaBanda, FWSPB) e salva todos os graficos NATIVOS do MATLAB
%  em ./figs/, alem de gravar o sinal recuperado (.mat / .wav).
%
%  Cada curva e salva como uma figura individual (no estilo do relatorio de
%  exemplo). As respostas em frequencia usam GANHO LINEAR e FASE EM GRAUS
%  (sem dB e sem radianos). Executar a partir da pasta que contem as funcoes
%  e o arquivo .mat.
%  Analise de Sistemas Lineares - UTFPR - Prof. Cesar Janeczko
%  ========================================================================
clear; close all; clc;

OUT = fullfile(pwd, 'figs');
if ~exist(OUT, 'dir'); mkdir(OUT); end
set(groot, 'defaultAxesFontSize', 11);
set(groot, 'defaultLineLineWidth', 1.0);

% ----------------------- parametros escolhidos --------------------------
FC_FPB = 0.10;  FC_FPA = 0.10;           % item 1/2 - polo simples
fs12   = 1000;  f_low = 30;  f_high = 350;
FC_BANDA = 0.25; BW_BANDA = 0.008;       % item 3/4 - banda estreita
fs34   = 1000;  tones4 = [40 120 250 380 470];
FC_LP5 = 0.05; M_WS5 = 400;              % item 5 - som: corte ~2 kHz (ruido e HF, sobe acima de 2 kHz), M grande => corte abrupto
% Interferencia = FAIXA de ~20 Hz (758-778 Hz, centro 768). Notch estreito
% fura so o meio e deixa o residuo em ~778 Hz; por isso bw largo o bastante.
F_NOTCH = 0.0192; BW_NOTCH = 0.006; N_CASC = 3;
M = 100;  imp = zeros(1, M); imp(1) = 1; % impulso (1 0 0 ... 100 pontos)

% =======================================================================
%  ITEM 1 - filtros de polo simples (FPB e FPA)
% =======================================================================
resposta_freq(CalculaFPBIIR(FC_FPB, imp), 'FPB', OUT, 'f1_fpb');
resposta_freq(CalculaFPAIIR(FC_FPA, imp), 'FPA', OUT, 'f1_fpa');

% =======================================================================
%  ITEM 2 - teste FPB/FPA com sinal de baixa + alta frequencia
% =======================================================================
n12 = 0:fs12-1;
x12 = sin(2*pi*f_low*n12/fs12) + sin(2*pi*f_high*n12/fs12);
fig_tempo(x12, 'Sinal gerado (30 + 350 Hz) no tempo', fullfile(OUT,'f2_sinal_tempo.png'));
fig_freq (x12, 'Sinal gerado (30 + 350 Hz) na frequencia', fullfile(OUT,'f2_sinal_freq.png'));
yb = CalculaFPBIIR(FC_FPB, x12);
fig_tempo(yb, 'Sinal filtrado com FPB no tempo', fullfile(OUT,'f2_fpb_tempo.png'));
fig_freq (yb, 'Sinal filtrado com FPB na frequencia', fullfile(OUT,'f2_fpb_freq.png'));
ya = CalculaFPAIIR(FC_FPA, x12);
fig_tempo(ya, 'Sinal filtrado com FPA no tempo', fullfile(OUT,'f2_fpa_tempo.png'));
fig_freq (ya, 'Sinal filtrado com FPA na frequencia', fullfile(OUT,'f2_fpa_freq.png'));

% =======================================================================
%  ITEM 3 - filtros de banda estreita (passa-banda e rejeita-banda)
% =======================================================================
resposta_freq(FiltroPassaBanda(BW_BANDA, FC_BANDA, imp),  'Passa-banda',   OUT, 'f3_bp');
resposta_freq(FiltroRejeitaBanda(BW_BANDA, FC_BANDA, imp),'Rejeita-banda', OUT, 'f3_br');

% =======================================================================
%  ITEM 4 - teste banda estreita com sinal multi-frequencia
% =======================================================================
n34 = 0:fs34-1;  x34 = zeros(1, fs34);
for ft = tones4; x34 = x34 + sin(2*pi*ft*n34/fs34); end
fig_tempo(x34, 'Sinal gerado (40,120,250,380,470 Hz) no tempo', fullfile(OUT,'f4_sinal_tempo.png'));
fig_freq (x34, 'Sinal gerado (5 senoides) na frequencia', fullfile(OUT,'f4_sinal_freq.png'));
ybp = FiltroPassaBanda(BW_BANDA, FC_BANDA, x34);
fig_tempo(ybp, 'Sinal filtrado com passa-banda no tempo', fullfile(OUT,'f4_bp_tempo.png'));
fig_freq (ybp, 'Sinal filtrado com passa-banda na frequencia', fullfile(OUT,'f4_bp_freq.png'));
ybr = FiltroRejeitaBanda(BW_BANDA, FC_BANDA, x34);
fig_tempo(ybr, 'Sinal filtrado com rejeita-banda no tempo', fullfile(OUT,'f4_br_tempo.png'));
fig_freq (ybr, 'Sinal filtrado com rejeita-banda na frequencia', fullfile(OUT,'f4_br_freq.png'));

% =======================================================================
%  ITEM 5 - processamento de som
% =======================================================================
S = load('SinalRuidoModulado1s2026.mat');
sinal = reshape(S.sinalModulado, 1, []);   % vetor linha
N = numel(sinal);  n = 0:N-1;

% (a) sinal recebido (ruido modulado)
fig_tempo(sinal, 'Sinal ruido modulado no tempo', fullfile(OUT,'f5_modulado_tempo.png'));
fig_freq (sinal, 'FFT do sinal ruido modulado', fullfile(OUT,'f5_modulado_freq.png'));

% (b) demodulacao espectral: x .* cos(pi*n) = (-1)^n
demod = sinal .* cos(pi*n);
fig_tempo(demod, 'Sinal demodulado no tempo', fullfile(OUT,'f5_demod_tempo.png'));
fig_freq (demod, 'FFT do sinal demodulado', fullfile(OUT,'f5_demod_freq.png'));

% (c) passa-baixas WindowSinc (remove ruido branco de alta frequencia)
h_ws = FWSPB(M_WS5, FC_LP5);
lp_full = conv(demod, h_ws);
lp = lp_full(M_WS5/2 + 1 : M_WS5/2 + N);   % alinhamento (mesmo N)
fig_tempo(lp, 'Sinal apos passa-baixas WindowSinc no tempo', fullfile(OUT,'f5_lp_tempo.png'));
fig_freq (lp, 'FFT do sinal apos passa-baixas', fullfile(OUT,'f5_lp_freq.png'));

% (d) rejeita-banda na FAIXA interferente (~758-778 Hz, centro 768), cascata 3x
rb = lp;
for kk = 1:N_CASC; rb = FiltroRejeitaBanda(BW_NOTCH, F_NOTCH, rb); end
fig_tempo(rb, 'Audio recuperado (apos rejeita-banda x3) no tempo', fullfile(OUT,'f5_final_tempo.png'));
fig_freq (rb, 'FFT do audio recuperado', fullfile(OUT,'f5_final_freq.png'));

% ----------------------- salva sinal recuperado -------------------------
sinal_recuperado = rb / max(abs(rb)) * 0.95;
audiowrite('sinal_recuperado.wav', sinal_recuperado, 40000);
save('sinal_recuperado.mat', 'sinal_recuperado');

disp('FIGURAS GERADAS COM SUCESSO.');

% =======================================================================
%  FUNCOES AUXILIARES DE PLOTAGEM (figuras individuais)
% =======================================================================
function resposta_freq(h, nome, OUT, prefixo)
% Salva 3 figuras: resposta no tempo, ganho (linear) e fase (graus).
    H = fft(h);  Mh = numel(h);  k = 0:Mh-1;
    fig_tempo(h, sprintf('%s no tempo', nome), fullfile(OUT, [prefixo '_tempo.png']));
    % ganho (linear)
    f = figure('Color','w','Position',[100 100 760 460]);
    plot(k, abs(H)); grid on; box on; xlim([0 Mh-1]);
    title(sprintf('Curva de ganho do %s', nome)); xlabel('bin'); ylabel('ganho (linear)');
    salvar(f, fullfile(OUT, [prefixo '_ganho.png']));
    % fase (graus)
    f = figure('Color','w','Position',[100 100 760 460]);
    plot(k, angle(H)*180/pi); grid on; box on; xlim([0 Mh-1]);
    ylim([-180 180]); yticks(-180:90:180);
    title(sprintf('Curva de fase do %s', nome)); xlabel('bin'); ylabel('fase (graus)');
    salvar(f, fullfile(OUT, [prefixo '_fase.png']));
end

function fig_tempo(s, titulo, arquivo)
% Plota um sinal no dominio do tempo (amostras).
    N = numel(s);
    f = figure('Color','w','Position',[100 100 760 460]);
    plot(0:N-1, s); grid on; box on; xlim([0 N-1]);
    title(titulo); xlabel('amostra');
    salvar(f, arquivo);
end

function fig_freq(s, titulo, arquivo)
% Plota o modulo da FFT de um sinal (bins).
    N = numel(s);
    f = figure('Color','w','Position',[100 100 760 460]);
    plot(0:N-1, abs(fft(s))); grid on; box on; xlim([0 N-1]);
    title(titulo); xlabel('bin'); ylabel('|FFT|');
    salvar(f, arquivo);
end

function salvar(f, arquivo)
% Exporta a figura em PNG (exportgraphics quando disponivel; senao print).
    try
        exportgraphics(f, arquivo, 'Resolution', 150);
    catch
        print(f, arquivo, '-dpng', '-r150');
    end
    close(f);
end
