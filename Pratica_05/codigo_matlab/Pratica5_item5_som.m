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
load(arquivo);                            % carrega a variavel "sinalModulado"
sinal = reshape(sinalModulado, 1, []);    % garante vetor linha
Fs = 40000;                               % frequencia de amostragem
N  = length(sinal);
n  = 0:N-1;

%% (a) Sinal recebido (ruido modulado)
figure('Name','Sinal modulado - tempo'); plot(sinal);
    title('Sinal ruido modulado');        xlabel('amostra');
figure('Name','Sinal modulado - FFT');   plot(abs(fft(sinal)));
    title('FFT do sinal ruido modulado'); xlabel('bin');

%% (b) Demodulacao espectral: multiplicar por cos(pi*n) = (-1)^n
% Equivale a misturar com a portadora de Nyquist (20 kHz), revertendo o
% espectro: o audio volta para as baixas frequencias.
demodulado = sinal .* cos(pi*n);
figure('Name','Sinal demodulado - tempo'); plot(demodulado);
    title('Sinal demodulado');            xlabel('amostra');
figure('Name','Sinal demodulado - FFT');   plot(abs(fft(demodulado)));
    title('FFT do sinal demodulado');     xlabel('bin');

%% (c) Passa-baixas WindowSinc: remove o ruido branco de alta frequencia
% O ruido e de ALTA frequencia: desprezivel abaixo de ~2 kHz e sobe ate o
% piso branco em ~3.5 kHz. A voz recuperavel esta abaixo de ~1.5 kHz. Logo o
% corte fica em ~2 kHz (0.05) para remover o "xiado" sem perder a fala.
fc = 0.05;             % ~2 kHz
M  = 400;              % muitos coef. => transicao ABRUPTA (corte bem definido)
h  = FWSPB(M, fc);
lp = conv(demodulado, h);
lp = lp(M/2+1 : M/2+N);                    % alinha (remove atraso de grupo) e mantem N amostras
figure('Name','Apos passa-baixas - tempo'); plot(lp);
    title('Sinal apos passa-baixas WindowSinc'); xlabel('amostra');
figure('Name','Apos passa-baixas - FFT');   plot(abs(fft(lp)));
    title('FFT apos passa-baixas');         xlabel('bin');

%% (d) Rejeita-banda na FAIXA interferente (~758-778 Hz), em cascata 3x
% A interferencia nao e um tom puro: ocupa uma faixa de ~20 Hz centrada em
% 768 Hz. Um notch estreito (bw pequeno) fura so o meio e deixa os ombros
% (o residuo reaparece em ~778 Hz). Por isso o notch precisa ser largo o
% suficiente para cobrir toda a faixa.
fnotch = 768/Fs;       % centro da faixa interferente (~0.0192)
bw     = 0.006;        % largura suficiente p/ cobrir os ~20 Hz da faixa
rb = lp;
for k = 1:3            % cascata: soma as atenuacoes de cada estagio (~-63 dB)
    rb = FiltroRejeitaBanda(bw, fnotch, rb);
end
figure('Name','Audio recuperado - tempo'); plot(rb);
    title('Audio recuperado (apos rejeita-banda x3)'); xlabel('amostra');
figure('Name','Audio recuperado - FFT');   plot(abs(fft(rb)));
    title('FFT do audio recuperado');       xlabel('bin');

%% (e) Reproduz e salva o resultado
sinal_recuperado = rb / max(abs(rb)) * 0.95;
sound(sinal_recuperado, Fs);                         % ouca a frase recuperada
audiowrite('sinal_recuperado.wav', sinal_recuperado, Fs);
save('sinal_recuperado.mat', 'sinal_recuperado');
disp('Item 5 concluido: ouca o audio e anote a frase recuperada.');
