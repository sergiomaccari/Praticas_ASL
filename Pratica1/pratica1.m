%% pratica1.m — Pratica 1: Convolucao e Correlacao (ASL - UTFPR 2026)
clear; clc; close all; %% limpa tudo

%% =========================================================
%% TAREFA 1 — Convolucao
%% =========================================================
fprintf('=== TAREFA 1: Convolucao ===\n\n');

%define sinais a e b
a = [0.2, 0.6, 0.2];
b = [1, 2, 3, 1];

% calculos de convolucao com a nossa funcao e com a padrao matlab
c_nossa   = convolucao(a, b); 
c_matlab = conv(a, b); 

% resultados e comparacao no ultimo print
fprintf('convolucao(a,b) = '); fprintf('%.4f ', c_nossa);   fprintf('\n');
fprintf('conv(a,b) = '); fprintf('%.4f ', c_matlab); fprintf('\n');
fprintf('Esperado = 0.2000 1.0000 2.0000 2.4000 1.2000 0.2000\n\n');

%% =========================================================
%% TAREFA 2 — Analise e Filtragem de Sinais
%% =========================================================
fprintf('=== TAREFA 2: Analise e Filtragem ===\n\n');

%frquencia amostragem, num amostragens e vetor indice discreto
fs = 1000; N = 1000; n = 1:N;
x(n) = cos(2*pi*(n-1)/100) + cos(2*pi*(n-1)/4);

% Componentes de frequencia:
%   cos(2*pi*(n-1)/100) -> periodo = 100 amostras -> f = fs/100 = 10 Hz
%   cos(2*pi*(n-1)/4)   -> periodo = 4 amostras   -> f = fs/4  = 250 Hz

X = abs(fft(x));
f_axis = (0:N-1)*(fs/N);

figure(1);
subplot(3,2,1);
plot(n, x);
title('sinal x original'); grid on;

subplot(3,2,2);
plot(f_axis, X);
title('abs da fft do sinal x'); grid on;

%verifica se os filtros arquivos existem
% 2.c — Filtragem (requer fpb.txt e fpa.txt no diretorio corrente)

fpb = load('filtrosPratica1/fpb.txt');
fpa = load('filtrosPratica1/fpa.txt');

y_pb = convolucao(fpb, x);
y_pa = convolucao(fpa, x);

subplot(3,2,3);
plot(y_pa);
title('sinal x filtrado com o fpa'); grid on;

subplot(3,2,4);
plot(y_pb);
title('sinal x filtrado com o fpb'); grid on;

subplot(3,2,5);
plot(abs(fft(y_pa)));
title('abs da fft do sinal x filtrado com o fpa'); grid on;

subplot(3,2,6);
plot(abs(fft(y_pb)));
title('abs da fft do sinal x filtrado com o fpb'); grid on;

% ==========================
figure(2);
subplot(2,2,1); 
plot(fpb); 
title('Resposta ao impulso do fpb, no tempo. Somatório=0'); xlabel('n'); grid on;

subplot(2,2,3); 
plot(fpa); 
title('Resposta ao impulso do fpb, no tempo. Somatório=0'); xlabel('n'); grid on;

subplot(2,2,2); 
plot(abs(fft(fpb)));
title('ganho do fltro fpb (ganho 1 em 0Hz)'); xlabel('Frequencia (Hz)'); grid on;

subplot(2,2,4); 
plot(abs(fft(fpa)));
title('ganho do fltro fpa (ganho 1 em 0Hz)'); xlabel('n'); ylabel('Amplitude'); grid on;

%% =========================================================
%% TAREFA 3 — Correlacao e Simulacao de Radar
%% =========================================================
fprintf('=== TAREFA 3: Correlacao ===\n\n');

%aqui o amigao passou já os comentarios e eu to no trabalho nao vou recomentar

% 3.a — Verificacao da funcao correlacao
r1 = correlacao([1,2,3],[1,2]);
r2 = correlacao([1,2],[1,2,3]);

fprintf('correlacao([1,2,3],[1,2]) = '); fprintf('%d ', r1); fprintf('\n');
fprintf('Esperado: 3 8 5 2\n');
fprintf('correlacao([1,2],[1,2,3]) = '); fprintf('%d ', r2); fprintf('\n');
fprintf('Esperado: 2 5 8 3\n\n');

% 3.b
x1=senoide(2.6,-2.6,0.25,15); %cria 1/4 de ciclo de uma senoide (sinal emitido pelo radar)

figure(3);
subplot(3,1,1);
plot(x1);
axis([0 1000 -1 3]);
x2=ruido(0,10,1000); %ruído com 1000 pontos
x3=x2;

for i=800:814
    x3(i)=x3(i)+x1(i-799);
end

subplot(3,1,2);
plot(x2,'b');
hold on;
plot(x3,'r'); %sinal recebido pelo radar
grid;
hold off;


% 3.c — Correlacao cruzada para deteccao
c=correlacao(x1,x3);
subplot(3,1,3);
plot(c);
xlim([0 1000]);
grid; 