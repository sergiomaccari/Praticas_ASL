%% ========================================================================
%  Pratica 5 - Filtros IIR  --  Item 5: Processamento de Som
%  Demodulacao do espectro + filtragem dos ruidos do arquivo
%  SinalRuidoModulado1s2026.mat
%  Requer: FWSPB.m e FiltroRejeitaBanda.m (na mesma pasta)
%  (em sala, se possivel use fone de ouvido)
%  ========================================================================
clear; close all; clc;

% O arquivo .mat esta na pasta acima (raiz da "Pratica 5"); ajuste se preciso.
arquivo = fullfile('..', 'SinalRuidoModulado1s2026.mat');
load(arquivo);                 % carrega a variavel "sinalModulado"
sinal = reshape(sinalModulado, 1, []);    % garante vetor linha
Fs = 40000;                    % frequencia de amostragem
N  = length(sinal);
n  = 0:N-1;

%% (a) Sinal recebido (ruido modulado)
figure('Name','Sinal modulado');
plot(sinal);            title('Sinal ruido modulado');        xlabel('amostra');
figure('Name','FFT modulado');
plot(abs(fft(sinal)));  title('FFT do Sinal ruido modulado'); xlabel('bin');

%% (b) Demodulacao espectral: multiplicar por cos(pi*n) = (-1)^n
% Equivale a misturar com a portadora de Nyquist (20 kHz), revertendo o
% espectro: o audio volta para as baixas frequencias.
demodulado = sinal .* cos(pi*n);
figure('Name','Sinal demodulado');
plot(demodulado);            title('Sinal demodulado');        xlabel('amostra');
figure('Name','FFT demodulado');
plot(abs(fft(demodulado)));  title('FFT do Sinal demodulado'); xlabel('bin');

%% (c) Passa-baixas WindowSinc: remove o ruido branco de alta frequencia
fc = 0.075;            % ~3 kHz (borda observada onde comeca o ruido branco)
M  = 100;
h  = FWSPB(M, fc);
lp = conv(demodulado, h);
lp = lp(M/2+1 : M/2+N);       % alinha (remove atraso de grupo) e mantem N amostras
figure('Name','Apos passa-baixas');
plot(lp);            title('Sinal apos passa-baixas WindowSinc'); xlabel('amostra');
figure('Name','FFT apos passa-baixas');
plot(abs(fft(lp)));  title('FFT apos passa-baixas');              xlabel('bin');

%% (d) Rejeita-banda estreito no tom interferente (~766 Hz), em cascata 3x
fnotch = 766/Fs;       % frequencia normalizada do tom (~0.01915)
bw     = 0.0008;       % banda muito estreita
rb = lp;
for k = 1:3            % cascata: soma as atenuacoes (dB) de cada estagio
    rb = FiltroRejeitaBanda(bw, fnotch, rb);
end
figure('Name','Audio recuperado');
plot(rb);            title('Audio recuperado (apos rejeita-banda x3)'); xlabel('amostra');
figure('Name','FFT audio recuperado');
plot(abs(fft(rb)));  title('FFT do audio recuperado');                  xlabel('bin');

%% (e) Reproduz e salva o resultado
sinal_recuperado = rb / max(abs(rb)) * 0.95;
sound(sinal_recuperado, Fs);                         % ouca a frase recuperada
audiowrite('sinal_recuperado.wav', sinal_recuperado, Fs);
save('sinal_recuperado.mat', 'sinal_recuperado');
disp('Item 5 concluido: ouca o audio e anote a frase recuperada.');
