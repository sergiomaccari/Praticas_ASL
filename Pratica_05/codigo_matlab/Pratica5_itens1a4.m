%% ========================================================================
%  Pratica 5 - Filtros IIR (Filtros Recursivos)  --  Itens 1 a 4
%  Analise de Sistemas Lineares - UTFPR - Prof. Cesar Janeczko
%  Requer: CalculaFPBIIR.m, CalculaFPAIIR.m, FiltroPassaBanda.m,
%          FiltroRejeitaBanda.m  (na mesma pasta)
%  ========================================================================
clear; close all; clc;

M   = 100;                 % filtros com 100 pontos
imp = zeros(1, M); imp(1) = 1;     % resposta ao impulso: (1 0 0 0 ... )

%% ----- Item 1: polo simples passa-baixas (FPB) e passa-altas (FPA) -------
fc_fpb = 0.10;             % frequencia de corte escolhida (normalizada)
fc_fpa = 0.10;

h_fpb = CalculaFPBIIR(fc_fpb, imp);
H = fft(h_fpb);
figure('Name','FPB - polo simples');
subplot(2,2,1); plot(h_fpb);            title('FPB no tempo - h[n]');       xlabel('amostra');
subplot(2,2,2); plot(abs(H));           title('Ganho FPB');                 xlabel('bin');
subplot(2,2,3); plot(20*log10(abs(H))); title('Atenuacao FPB (dB)');        xlabel('bin');
subplot(2,2,4); plot(angle(H));         title('Fase FPB (rad)');            xlabel('bin');

h_fpa = CalculaFPAIIR(fc_fpa, imp);
H = fft(h_fpa);
figure('Name','FPA - polo simples');
subplot(2,2,1); plot(h_fpa);            title('FPA no tempo - h[n]');       xlabel('amostra');
subplot(2,2,2); plot(abs(H));           title('Ganho FPA');                 xlabel('bin');
subplot(2,2,3); plot(20*log10(abs(H))); title('Atenuacao FPA (dB)');        xlabel('bin');
subplot(2,2,4); plot(angle(H));         title('Fase FPA (rad)');            xlabel('bin');

%% ----- Item 2: teste FPB/FPA com sinal de baixa + alta frequencia --------
fs = 1000; n = 0:999;
fb = 30; fa = 350;                 % 30 Hz (baixa) + 350 Hz (alta)
x  = sin(2*pi*fb*n/fs) + sin(2*pi*fa*n/fs);
yb = CalculaFPBIIR(fc_fpb, x);
ya = CalculaFPAIIR(fc_fpa, x);
figure('Name','Item 2 - teste FPB/FPA');
subplot(3,2,1); plot(x);  title('Sinal gerado - tempo');  subplot(3,2,2); plot(abs(fft(x)));  title('Sinal gerado - |FFT|');
subplot(3,2,3); plot(yb); title('Filtrado FPB - tempo');  subplot(3,2,4); plot(abs(fft(yb))); title('Filtrado FPB - |FFT|');
subplot(3,2,5); plot(ya); title('Filtrado FPA - tempo');  subplot(3,2,6); plot(abs(fft(ya))); title('Filtrado FPA - |FFT|');

%% ----- Item 3: banda estreita - passa-banda e rejeita-banda --------------
fc_b = 0.25; bw = 0.008;           % centro em 0.25 (=250 Hz se fs=1000), BW estreito

h_bp = FiltroPassaBanda(bw, fc_b, imp);
H = fft(h_bp);
figure('Name','Passa-banda');
subplot(2,2,1); plot(h_bp);             title('Passa-banda no tempo');  xlabel('amostra');
subplot(2,2,2); plot(abs(H));           title('Ganho passa-banda');     xlabel('bin');
subplot(2,2,3); plot(20*log10(abs(H))); title('Atenuacao (dB)');        xlabel('bin');
subplot(2,2,4); plot(angle(H));         title('Fase (rad)');            xlabel('bin');

h_br = FiltroRejeitaBanda(bw, fc_b, imp);
H = fft(h_br);
figure('Name','Rejeita-banda');
subplot(2,2,1); plot(h_br);             title('Rejeita-banda no tempo'); xlabel('amostra');
subplot(2,2,2); plot(abs(H));           title('Ganho rejeita-banda');    xlabel('bin');
subplot(2,2,3); plot(20*log10(abs(H))); title('Atenuacao (dB)');         xlabel('bin');
subplot(2,2,4); plot(angle(H));         title('Fase (rad)');             xlabel('bin');

%% ----- Item 4: teste banda estreita com sinal multi-frequencia -----------
tones = [40 120 250 380 470];      % varias frequencias (compativel com fc_b)
x4 = zeros(1, 1000);
for f = tones
    x4 = x4 + sin(2*pi*f*n/fs);
end
ybp = FiltroPassaBanda(bw, fc_b, x4);
ybr = FiltroRejeitaBanda(bw, fc_b, x4);
figure('Name','Item 4 - teste banda estreita');
subplot(3,2,1); plot(x4);  title('Sinal gerado - tempo');         subplot(3,2,2); plot(abs(fft(x4)));  title('Sinal gerado - |FFT|');
subplot(3,2,3); plot(ybp); title('Passa-banda (250 Hz) - tempo'); subplot(3,2,4); plot(abs(fft(ybp))); title('Passa-banda - |FFT|');
subplot(3,2,5); plot(ybr); title('Rejeita-banda (250 Hz) - tempo'); subplot(3,2,6); plot(abs(fft(ybr))); title('Rejeita-banda - |FFT|');

disp('Itens 1 a 4 concluidos.');
