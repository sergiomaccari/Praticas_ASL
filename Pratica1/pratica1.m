%% pratica1.m — Pratica 1: Convolucao e Correlacao (ASL - UTFPR 2026)
clear; clc; close all;

% Adiciona caminho das funcoes auxiliares da Pratica 0
addpath('../Pratica 0/ArquivosM');

%% =========================================================
%% TAREFA 1 — Convolucao
%% =========================================================
fprintf('=== TAREFA 1: Convolucao ===\n');

a = [0.2, 0.6, 0.2];
b = [1, 2, 3, 1];

c_nossa   = convolucao(a, b);
c_builtin = conv(a, b);

fprintf('convolucao(a,b) = '); fprintf('%.4f ', c_nossa);   fprintf('\n');
fprintf('conv(a,b)       = '); fprintf('%.4f ', c_builtin); fprintf('\n');
fprintf('Esperado        = 0.2000 1.0000 2.0000 2.4000 1.2000 0.2000\n');
fprintf('Erro maximo: %.2e\n\n', max(abs(c_nossa - c_builtin)));

figure(1);
subplot(3,1,1); stem(a,'filled'); title('Sinal a'); xlabel('n'); ylabel('Amplitude'); grid on;
subplot(3,1,2); stem(b,'filled'); title('Sinal b'); xlabel('n'); ylabel('Amplitude'); grid on;
subplot(3,1,3);
stem(c_nossa,'filled'); hold on; stem(c_builtin,'r*'); hold off;
title('Convolucao: nossa (azul) vs conv() (vermelho)');
xlabel('n'); ylabel('Amplitude'); grid on; legend('convolucao()','conv()');

%% =========================================================
%% TAREFA 2 — Analise e Filtragem de Sinais
%% =========================================================
fprintf('=== TAREFA 2: Analise e Filtragem ===\n');

fs = 1000; N = 1000; n = 1:N;
x = cos(2*pi*(n-1)/100) + cos(2*pi*(n-1)/4);
% Componentes de frequencia:
%   cos(2*pi*(n-1)/100) -> periodo = 100 amostras -> f = fs/100 = 10 Hz
%   cos(2*pi*(n-1)/4)   -> periodo = 4 amostras   -> f = fs/4  = 250 Hz
fprintf('Componentes de frequencia: 10 Hz e 250 Hz\n');

figure(2);
subplot(2,1,1);
stem(n(1:100), x(1:100),'filled');
title('x(n) — primeiras 100 amostras (tempo discreto)');
xlabel('n (amostras)'); ylabel('Amplitude'); grid on;

subplot(2,1,2);
X = abs(fft(x));
f_axis = (0:N-1)*(fs/N);
plot(f_axis(1:N/2), X(1:N/2));
title('Espectro |FFT(x)|'); xlabel('Frequencia (Hz)'); ylabel('|X(f)|'); grid on;
fprintf('Picos esperados no espectro: 10 Hz e 250 Hz\n\n');

% 2.c — Filtragem (requer fpb.txt e fpa.txt no diretorio corrente)
if exist('fpb.txt','file') && exist('fpa.txt','file')
    fpb = load('fpb.txt');
    fpa = load('fpa.txt');

    y_pb = convolucao(fpb, x);
    y_pa = convolucao(fpa, x);

    figure(3);
    subplot(2,2,1); stem(fpb,'filled'); title('Resposta ao impulso — FPB'); xlabel('n'); grid on;
    subplot(2,2,2); plot(f_axis(1:N/2), abs(fft(fpb,N))(1:N/2));
                    title('Espectro do filtro FPB'); xlabel('Frequencia (Hz)'); grid on;
    subplot(2,2,3); plot(y_pb(1:min(200,end)));
                    title('Sinal filtrado (FPB) — tempo'); xlabel('n'); ylabel('Amplitude'); grid on;
    subplot(2,2,4); plot(f_axis(1:N/2), abs(fft(y_pb,N))(1:N/2));
                    title('Espectro do sinal filtrado (FPB)'); xlabel('Hz'); grid on;

    figure(4);
    subplot(2,2,1); stem(fpa,'filled'); title('Resposta ao impulso — FPA'); xlabel('n'); grid on;
    subplot(2,2,2); plot(f_axis(1:N/2), abs(fft(fpa,N))(1:N/2));
                    title('Espectro do filtro FPA'); xlabel('Frequencia (Hz)'); grid on;
    subplot(2,2,3); plot(y_pa(1:min(200,end)));
                    title('Sinal filtrado (FPA) — tempo'); xlabel('n'); ylabel('Amplitude'); grid on;
    subplot(2,2,4); plot(f_axis(1:N/2), abs(fft(y_pa,N))(1:N/2));
                    title('Espectro do sinal filtrado (FPA)'); xlabel('Hz'); grid on;

    fprintf('FPB deve preservar 10 Hz e atenuar 250 Hz.\n');
    fprintf('FPA deve preservar 250 Hz e atenuar 10 Hz.\n\n');
else
    fprintf('AVISO: fpb.txt e/ou fpa.txt nao encontrados.\n');
    fprintf('Coloque os arquivos no diretorio:\n  %s\n', pwd);
    fprintf('e rode o script novamente.\n\n');
end

%% =========================================================
%% TAREFA 3 — Correlacao e Simulacao de Radar
%% =========================================================
fprintf('=== TAREFA 3: Correlacao ===\n');

% 3.a — Verificacao da funcao correlacao
r1 = correlacao([1,2,3],[1,2]);
r2 = correlacao([1,2],[1,2,3]);
fprintf('correlacao([1,2,3],[1,2]) = '); fprintf('%d ', r1); fprintf('\n');
fprintf('Esperado:                   3 8 5 2\n');
fprintf('correlacao([1,2],[1,2,3]) = '); fprintf('%d ', r2); fprintf('\n');
fprintf('Esperado:                   2 5 8 3\n\n');

% 3.b — Simulacao de radar
x1 = senoide(2.6, -2.6, 0.25, 15);   % sinal transmitido (15 amostras)
x2 = ruido(0, 10, 1000);              % ruido de fundo (1000 amostras)
x3 = x2;                              % sinal recebido = ruido + eco
x3(800:814) = x3(800:814) + x1;       % embutir x1 nas amostras 800-814

% 3.c — Correlacao cruzada para deteccao
c_radar = correlacao(x3, x1);
[pico_val, pico_idx] = max(abs(c_radar));
fprintf('Comprimento de correlacao(x3,x1): %d\n', length(c_radar));
fprintf('Pico em indice: %d (esperado ~814), valor: %.4f\n\n', pico_idx, pico_val);

figure(5);
subplot(3,1,1);
stem(1:length(x1), x1,'filled');
title('x1 — Sinal transmitido (15 amostras de senoide)');
xlabel('n'); ylabel('Amplitude'); grid on;

subplot(3,1,2);
plot(1:1000, x2,'b'); hold on;
plot(1:1000, x3,'r'); hold off;
title('x2 (ruido, azul) vs x3 (sinal recebido, vermelho)');
xlabel('n'); ylabel('Amplitude'); grid on; legend('x2 ruido','x3 recebido');

subplot(3,1,3);
plot(1:length(c_radar), abs(c_radar)); hold on;
plot(pico_idx, pico_val,'rv','MarkerSize',10,'MarkerFaceColor','r'); hold off;
title(sprintf('|correlacao(x3, x1)| — pico detectado no indice %d', pico_idx));
xlabel('n'); ylabel('|Correlacao|'); grid on;

fprintf('Pratica 1 concluida.\n');
