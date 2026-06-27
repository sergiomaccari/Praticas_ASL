%% Prática 5 - Filtros IIR (Filtros Recursivos) / Áudio
clear; clc; close all;

%% =========================================================
%% 1) Filtros de Pólo Simples (R-C) Passa-Baixas e Passa-Altas
%% =========================================================
% Gera o impulso de 100 pontos: [1, 0, 0, 0...]
imp = zeros(1, 100); 
imp(1) = 1.0;

fc_1 = 0.1; % Escolha da frequência de corte normalizada

% Calcula a resposta ao impulso dos filtros recursivos
h_fpb = CalculaFPBIIR(fc_1, imp);
h_fpa = CalculaFPAIIR(fc_1, imp);

% Plotagem: Resposta ao impulso, Ganho, Atenuação e Fase
plot_iir_style(h_fpb, '1 - FPB Pólo Simples', 1);
plot_iir_style(h_fpa, '1 - FPA Pólo Simples', 2);

%% =========================================================
%% 2) Teste do Pólo Simples com Sinal de Múltiplas Frequências
%% =========================================================
n = 0:199;
% Sinal composto: Baixa (0.02) + Alta (0.4) frequência
x1 = sin(2*pi*0.02*n) + sin(2*pi*0.4*n);

% Aplica a equação de diferença (IIR) no sinal gerado
y1_fpb = CalculaFPBIIR(fc_1, x1);
y1_fpa = CalculaFPAIIR(fc_1, x1);

figure(3); set(gcf, 'Name', '2 - Teste Filtros IIR (Tempo e Freq)');
% Original
subplot(3,2,1); plot(n, x1); title('Sinal x1(n) Original');
subplot(3,2,2); plot(abs(fft(x1))); title('|FFT| x1(n)'); xlim([0 length(x1)]);
% Passa-Baixas
subplot(3,2,3); plot(n, y1_fpb); title('x1 Filtrado - FPB');
subplot(3,2,4); plot(abs(fft(y1_fpb))); title('|FFT| FPB'); xlim([0 length(y1_fpb)]);
% Passa-Altas
subplot(3,2,5); plot(n, y1_fpa); title('x1 Filtrado - FPA');
subplot(3,2,6); plot(abs(fft(y1_fpa))); title('|FFT| FPA'); xlim([0 length(y1_fpa)]);

%% =========================================================
%% 3) Filtros Banda Estreita (Passa-Banda e Corta-Banda)
%% =========================================================
fc_3 = 0.2;  % Frequência central do filtro
bw = 0.02;   % Largura de banda estreita

h_fpf = FiltroPassaBanda(bw, fc_3, imp);
h_fcf = FiltroRejeitaBanda(bw, fc_3, imp);

plot_iir_style(h_fpf, '3 - Passa-Banda Estreita', 4);
plot_iir_style(h_fcf, '3 - Corta-Banda Estreita', 5);

%% =========================================================
%% 4) Teste do Banda Estreita com Sinal de Várias Frequências
%% =========================================================
% Sinal composto: freq abaixo (0.05) + no centro (0.2) + acima (0.4)
x2 = sin(2*pi*0.05*n) + sin(2*pi*0.2*n) + sin(2*pi*0.4*n);

y2_fpf = FiltroPassaBanda(bw, fc_3, x2);
y2_fcf = FiltroRejeitaBanda(bw, fc_3, x2);

figure(6); set(gcf, 'Name', '4 - Teste Banda Estreita');
% Original
subplot(3,2,1); plot(n, x2); title('Sinal x2(n) Original');
subplot(3,2,2); plot(abs(fft(x2))); title('|FFT| x2(n)'); xlim([0 length(x2)]);
% Passa-Banda (Isola o 0.2)
subplot(3,2,3); plot(n, y2_fpf); title('x2 Filtrado - Passa Banda');
subplot(3,2,4); plot(abs(fft(y2_fpf))); title('|FFT| FPF'); xlim([0 length(y2_fpf)]);
% Corta-Banda (Remove o 0.2)
subplot(3,2,5); plot(n, y2_fcf); title('x2 Filtrado - Corta Banda');
subplot(3,2,6); plot(abs(fft(y2_fcf))); title('|FFT| FCF'); xlim([0 length(y2_fcf)]);

%% =========================================================
%% 5) Processamento de Áudio - Demodulação e Filtragem
%% =========================================================
if isfile('Sinal Ruido Modulado1s2026.mat')
    load('Sinal Ruido Modulado1s2026.mat');
    sinal = sinalModulado(:); % Garante vetor coluna
    Fs = 40000;
    
    n_som = (0:length(sinal)-1)';
    
    % PASSO A - DEMODULAÇÃO
    % A portadora usa a máxima frequência digital (Nyquist) que é Fs/2.
    % Em frequência normalizada: 0.5. A equação é: cos(2*pi*0.5*n) = cos(pi*n)
    portadora = cos(pi * n_som);
    sinal_demod = sinal .* portadora;
    
    % PASSO B - FILTRO PASSA-BAIXAS (WindowSinc)
    % Remove o espelho espectral da demodulação. Voz tipicamente < 4kHz.
    % Freq corte normalizada: 4000 / 40000 = 0.1
    h_sinc = FWSPB(100, 0.1);
    sinal_base = conv(sinal_demod, h_sinc, 'same');
    
    figure(7); set(gcf, 'Name', '5 - FFT do Áudio Demodulado');
    plot(abs(fft(sinal_base))); 
    title('Espectro Base - Procure os picos de ruído aqui!');
    
    % PASSO C - FILTRO CORTA FAIXA ESTREITA
    % O PDF adverte: "pode ser preciso filtrar mais de uma vez!"
    % Preencha o vetor abaixo com as frequências normalizadas (ciclos/amostra) 
    % onde os picos indesejados aparecerem no gráfico 7.
    f_ruidos = [0.15, 0.20]; % SUBSTITUA PELAS FREQUÊNCIAS REAIS QUE ENCONTRAR
    bw_ruido = 0.005;
    
    sinal_limpo = sinal_base;
    for f_r = f_ruidos
        % Filtra em cascata limpando as componentes indesejadas
        sinal_limpo = FiltroRejeitaBanda(bw_ruido, f_r, sinal_limpo);
    end
    
    % Normalização para escutar
    sinal_limpo = sinal_limpo / max(abs(sinal_limpo));
    
    disp('Reproduzindo áudio filtrado...');
    sound(sinal_limpo, Fs);
    % audiowrite('sinal_filtrado.wav', sinal_limpo, Fs);
else
    disp('Arquivo de áudio não encontrado na pasta.');
end


%% =========================================================
%% FUNÇÕES NÚCLEO DSP
%% =========================================================

function y = CalculaFPBIIR(fc, x)
    nx = length(x);
    r = exp(-2*pi*fc);
    a0 = 1 - r;
    b1 = r;
    y = zeros(1, nx);
    if nx >= 1, y(1) = a0*x(1); end
    for i = 2:nx
        y(i) = a0*x(i) + b1*y(i-1);
    end
end

function y = CalculaFPAIIR(fc, x)
    nx = length(x);
    r = exp(-2*pi*fc);
    a0 = (1 + r)/2;
    a1 = -(1 + r)/2;
    b1 = r;
    y = zeros(1, nx);
    if nx >= 1, y(1) = a0*x(1); end
    for i = 2:nx
        y(i) = a0*x(i) + a1*x(i-1) + b1*y(i-1);
    end
end

function y = FiltroPassaBanda(bw, f, x)
    nx = length(x);
    r = 1 - 3*bw;
    k = (1 - 2*r*cos(2*pi*f) + r^2) / (2 - 2*cos(2*pi*f));
    a0 = 1 - k;
    a1 = 2*(k - r)*cos(2*pi*f);
    a2 = r^2 - k;
    b1 = 2*r*cos(2*pi*f);
    b2 = -r^2;
    y = zeros(1, nx);
    if nx >= 1, y(1) = a0*x(1); end
    if nx >= 2, y(2) = a0*x(2) + a1*x(1) + b1*y(1); end
    for i = 3:nx
        y(i) = a0*x(i) + a1*x(i-1) + a2*x(i-2) + b1*y(i-1) + b2*y(i-2);
    end
end

function y = FiltroRejeitaBanda(bw, f, x)
    nx = length(x);
    r = 1 - 3*bw;
    k = (1 - 2*r*cos(2*pi*f) + r^2) / (2 - 2*cos(2*pi*f));
    a0 = k;
    a1 = -2*k*cos(2*pi*f);
    a2 = k;
    b1 = 2*r*cos(2*pi*f);
    b2 = -r^2;
    y = zeros(1, nx);
    if nx >= 1, y(1) = a0*x(1); end
    if nx >= 2, y(2) = a0*x(2) + a1*x(1) + b1*y(1); end
    for i = 3:nx
        y(i) = a0*x(i) + a1*x(i-1) + a2*x(i-2) + b1*y(i-1) + b2*y(i-2);
    end
end

function H = FWSPB(M, FC)
    % Filtro Window-sinc (FIR) da Prática 4
    H = zeros(1, M);
    m2 = M/2;
    for i = 1:M
        if (i - m2) == 0
            H(i) = 2*pi*FC;
        else
            H(i) = sin(2*pi*FC*(i - m2)) / (i - m2);
        end
        w = 0.42 - 0.5*cos(2*pi*i/M) + 0.08*cos(4*pi*i/M);
        H(i) = H(i) * w;
    end
    H = H / sum(H);
end

function plot_iir_style(h, fig_name, fig_num)
    % Plota Impulso, Ganho, Atenuação e Fase
    figure(fig_num);
    set(gcf, 'Name', fig_name);
    
    nx = 0:(length(h)-1);
    
    subplot(4,1,1);
    plot(nx, h); xlim([0 nx(end)]);
    title('Resposta ao Impulso');
    
    H_fft = fft(h);
    mag = abs(H_fft);
    fase = angle(H_fft); % Em radianos (-pi a pi)
    
    subplot(4,1,2);
    plot(nx, mag); xlim([0 nx(end)]);
    title('Ganho (linear)');
    
    subplot(4,1,3);
    H_db = 20*log10(max(mag, 1e-10));
    plot(nx, H_db); xlim([0 nx(end)]);
    title('Atenuação (dB)');
    
    subplot(4,1,4);
    plot(nx, unwrap(fase)); xlim([0 nx(end)]);
    title('Fase');
end