%% Prática 4 - Filtros Window-sinc (FIR) / Imagem Híbrida
clear; clc; close all;

%% =========================================================
%% Questão 1 e 2.a) FPB com Janela de Blackman
%% =========================================================
M = 100; FC = 0.15;
fpb = FWSPB(M, FC);

plot_prof_style(fpb, 'Figure 1 - FPB com janela', ...
    '', ... 
    'Ganho - filtro passa baixas com janela', ...
    'Atenuação - filtro passa baixas com janela', 1);

%% =========================================================
%% Questão 2.b) FPB SEM Janela (Retangular)
%% =========================================================
fpb_sj = FWSPB_semjanela(M, FC);

plot_prof_style(fpb_sj, 'Figure 2 - FPB SEM janela', ...
    '', ... 
    'Ganho - filtro passa baixas SEM janela', ...
    'Atenuação - filtro passa baixas SEM janela', 2);

%% =========================================================
%% Questão 3) FPA por Inversão Espectral
%% =========================================================
fpa = FWSPA(M, FC);

plot_prof_style(fpa, 'Figure 3 - FPA com janela', ...
    '', ...
    'Ganho - filtro passa alta com janela', ...
    'Atenuação - filtro passa alta com janela', 3);

%% =========================================================
%% Questão 4) FPF (Passa-Faixa) e FCF (Corta-Faixa)
%% =========================================================
fci = 0.15; fcs = 0.30;
% Passa-faixa: Subtração de dois passa-baixas (M=100 preservado)
fpf = FWSPB(100, fcs) - FWSPB(100, fci);
% Corta-faixa: Soma paralela de Passa-baixa e Passa-alta (M=100 preservado)
fcf = FWSPB(100, fci) + FWSPA(100, fcs);     

% Gera o Corta-Faixa em uma janela exclusiva 
plot_prof_style(fcf, 'Figure 4 - Corta-Faixa', ...
    '', ...
    'Ganho - filtro corta faixa', ...
    'Atenuação - filtro corta faixa', 4);

% Gera o Passa-Faixa em uma janela exclusiva 
plot_prof_style(fpf, 'Figure 5 - Passa-Faixa', ...
    '', ...
    'Ganho - filtro passa faixa', ...
    'Atenuação - filtro passa faixa', 5);

%% =========================================================
%% Questão 5) Sinal x(n) e Filtragens (Gráficos Separados)
%% =========================================================
n = 1:1000;
x = sin(pi*100*n/1000) + sin(pi*500*n/1000) + sin(pi*800*n/1000);

% 5.1 - Sinal Original Isolado
figure(6);
set(gcf, 'Name', 'Sinal Original x(n)');
subplot(2,1,1); plot(n, x); title('Sinal Original no Tempo');
subplot(2,1,2); plot(abs(fft(x))); title('Espectro |FFT| Original'); xlim([0 1000]);

% 5.2 - Filtros Básicos (FPB e FPA)
figure(7);
set(gcf, 'Name', 'Filtragens Básicas (FPB e FPA)');
y_pb = conv(x, fpb);
y_pa = conv(x, fpa);

subplot(2,2,1); plot(y_pb); title('Sinal Filtrado - FPB');
subplot(2,2,2); plot(abs(fft(y_pb))); title('|FFT| - FPB'); xlim([0 length(y_pb)]);
subplot(2,2,3); plot(y_pa); title('Sinal Filtrado - FPA');
subplot(2,2,4); plot(abs(fft(y_pa))); title('|FFT| - FPA'); xlim([0 length(y_pa)]);

% 5.3 - Filtros de Faixa (FPF e FCF)
figure(8);
set(gcf, 'Name', 'Filtragens de Faixa (FPF e FCF)');
y_pf = conv(x, fpf);
y_cf = conv(x, fcf);

subplot(2,2,1); plot(y_pf); title('Sinal Filtrado - FPF');
subplot(2,2,2); plot(abs(fft(y_pf))); title('|FFT| - FPF'); xlim([0 length(y_pf)]);
subplot(2,2,3); plot(y_cf); title('Sinal Filtrado - FCF');
subplot(2,2,4); plot(abs(fft(y_cf))); title('|FFT| - FCF'); xlim([0 length(y_cf)]);

%% =========================================================
%% Questão 6) Explicação do Deslocamento das Raias
%% =========================================================
disp('--- Questão 6 ---');
disp('As raias na FFT do sinal filtrado mudam de bin porque a convolução');
disp('aumenta o comprimento do sinal de N (1000) para N+M (1100).');
disp('A frequência real não muda, mas a "escala de bins" da FFT é alongada.');
disp('Nova posição do bin: k_novo = k_original * (1100 / 1000).');

%% =========================================================
%% Questão 7) Imagem Híbrida
%% =========================================================
if isfile('ImagemHibrida1s2025.mat')
    load('ImagemHibrida1s2025.mat');
    IH = Imagem_hibrida;
    
    fc_img = 0.05; M_img = 60;
    ws_pb = FWSPB(M_img, fc_img);
    ws_pa = FWSPA(M_img, fc_img);
    
    [rows, cols] = size(IH);
    ini = M_img / 2; 
    
    hibrida_PB = zeros(rows, cols);
    hibrida_PA = zeros(rows, cols);
    
    for i = 1:rows
        lin_pb = conv(IH(i, :), ws_pb);
        lin_pa = conv(IH(i, :), ws_pa);
        hibrida_PB(i, :) = lin_pb(ini + 1 : ini + cols);
        hibrida_PA(i, :) = lin_pa(ini + 1 : ini + cols);
    end
    
    figure(9);
    set(gcf, 'Name', 'Separação da Imagem Híbrida');
    subplot(1,3,1); imshow(IH, []); title('Original Híbrida');
    subplot(1,3,2); imshow(hibrida_PB, []); title('Marilyn (FPB)');
    subplot(1,3,3); imshow(hibrida_PA, []); title('Einstein (FPA)');
    
    figure(10);
    set(gcf, 'Name', 'Espectro de todas as linhas');
    plot(abs(fft(IH'))); 
    title('abs(fft(ImagemHibrida)) de todas as linha');
    xlabel('Bins da FFT (Índice da coluna)');
    ylabel('Magnitude |FFT|');
    xlim([0 450]); 
else
    disp('Arquivo ImagemHibrida1s2025.mat não encontrado na pasta.');
end

%% =========================================================
%% FUNÇÕES AUXILIARES (AGORA DE 1 ATÉ M)
%% =========================================================
function H = FWSPB(M, FC)
    H = zeros(1, M);
    m2 = M/2;
    for i = 1:M
        if (i - m2) == 0
            H(i) = 2*pi*FC;
        else
            H(i) = sin(2*pi*FC*(i - m2)) / (i - m2);
        end
        % Janela de Blackman ajustada para contar a partir de 1
        w = 0.42 - 0.5*cos(2*pi*i/M) + 0.08*cos(4*pi*i/M);
        H(i) = H(i) * w;
    end
    H = H / sum(H); 
end

function H = FWSPB_semjanela(M, FC)
    H = zeros(1, M);
    m2 = M/2;
    for i = 1:M
        if (i - m2) == 0
            H(i) = 2*pi*FC;
        else
            H(i) = sin(2*pi*FC*(i - m2)) / (i - m2);
        end
    end
    H = H / sum(H); 
end

function H = FWSPA(M, FC)
    H = FWSPB(M, FC);
    H = -H;
    H(M/2) = H(M/2) + 1; % Soma o impulso unitário perfeitamente no centro
end

function plot_prof_style(h, fig_name, title_tempo, title_ganho, title_atenuacao, fig_num)
    figure(fig_num);
    set(gcf, 'Name', fig_name);
    
    % Dominio do tempo
    subplot(3,1,1);
    if length(h) == 100 && fig_num == 1  
        plot(h, '-o'); 
    else
        plot(h);
    end
    xlim([0 100]);
    if ~isempty(title_tempo)
        title(title_tempo);
    end
    
    % Ganho Linear
    H_fft = abs(fft(h));
    
    subplot(3,1,2);
    plot(H_fft);
    xlim([0 100]);
    title(title_ganho);
    
    % Atenuação em dB
    H_db = 20*log10(max(H_fft, 1e-10)); 
    subplot(3,1,3);
    plot(H_db);
    xlim([0 100]);
    title(title_atenuacao);
end