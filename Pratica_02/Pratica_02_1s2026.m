%% Prática 1: Transformada Discreta de Fourier - DFT
clear; clc; close all;

fs = 1000; % Frequência de amostragem (Hz)
N = 1000;  % Tamanho da janela
n = 1:N;   % Índice da amostra (1 a 1000)

% a) e b) Elaboração do sinal x(n)
x = cos(pi*(n-1)/50) + cos(pi*(n-1)/5.5) + sin(pi*(n-1)/5);

% d) Comparação de tempo entre algoritmo próprio e FFT do MATLAB
disp('Calculando DFT customizada...');
tic();
dftx = DFT(x);
tempo_dft = toc();
fprintf('Tempo DFT: %f segundos\n', tempo_dft);

disp('Calculando FFT nativa...');
tic();
fftx = fft(x);
tempo_fft = toc();
fprintf('Tempo FFT: %f segundos\n', tempo_fft);

% e) Plotagem dos gráficos abs, real e imag
figure('Name', 'Prática 1 - Análise do Sinal x(n)');
subplot(3,1,1);
plot(abs(dftx)); title('abs DFT');
subplot(3,1,2);
plot(real(dftx)); title('real DFT');
subplot(3,1,3);
plot(imag(dftx)); title('imag DFT');

%% Prática 2: Aumentar a resolução em frequência (Zero-padding)
% Sinal reduzido para 150 pontos
N1 = 150;
n1 = 1:N1;
x1 = cos(pi*(n1-1)/50) + cos(pi*(n1-1)/5.5) + sin(pi*(n1-1)/5);

figure('Name', 'Prática 2 - x1 com 150 pontos vs Zero-Padding');

% Plot x1 no tempo (150 pontos)
subplot(2,2,1);
plot(x1); title('x1 (150 pontos) no Tempo');

% Plot x1 na frequência (150 pontos)
subplot(2,2,2);
plot(abs(DFT(x1)), 'o-'); title('DFT x1 (150 pontos)');

% Preenchendo com zeros até 1000 pontos
x1_zp = [x1, zeros(1, N - N1)];

% Plot x1 preenchido no tempo
subplot(2,2,3);
plot(x1_zp); title('x1 (Zero-padded 1000 pt) no Tempo');

% Plot x1 preenchido na frequência
subplot(2,2,4);
plot(abs(DFT(x1_zp)), 'o-'); title('DFT x1 (Zero-padded)');

%% Prática 3: Resposta em Frequência de Filtro
% a) Carregar o filtro fpf.mat
% Certifique-se de que o arquivo fpf.mat está no mesmo diretório
load('fpf.mat'); % Deve carregar uma variável no workspace, vamos assumir que se chama 'fpf'
% OBS: Substitua 'fpf' abaixo pelo nome exato da variável que for carregada do .mat.

figure('Name', 'Prática 3 - Resposta em Frequência (Filtro)');

% Plot da resposta ao impulso original
subplot(2,2,1);
plot(fpf, 'o-'); title('Resposta ao Impulso Original (hFPF)');

% Curva de Ganho (abs(DFT))
subplot(2,2,2);
plot(abs(DFT(fpf)), 'o-'); title('Ganho Original');

% b) Preencher fpf com zeros até 1000 pontos
fpf_zp = [fpf(:)', zeros(1, 1000 - length(fpf))];

subplot(2,2,3);
plot(fpf_zp, '.-'); title('hFPF com Zero-Padding');

subplot(2,2,4);
plot(abs(DFT(fpf_zp)), '.-'); title('Ganho com Zero-Padding');