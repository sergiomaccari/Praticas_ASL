%% Pratica 3 - Amostragem e Quantizacao
%% Leonardo Pereira Shibata / Sergio Roncato Maccari - 1s2026
clear; clc; close all;

if ~exist('imgs', 'dir'); mkdir('imgs'); end
salvar = @(nome) exportgraphics(gcf, fullfile('imgs', [nome '.png']), 'Resolution', 150);

%% =========================================================
%% Q1 - Amostragem e Quantizacao
%% =========================================================
% Sinal "continuo" 10 Hz com 1000 pontos e amostrado com 100 pontos
s10           = senoide(128, -127, 10, 1000);
s10amostrado  = senoide(128, -127, 10, 100);
indice        = 1:10:1000;

% --- 1.b) 2 bits FLOOR (quantiza.m usa floor)
figure('Name', '1.b) Quantizacao 2 bits FLOOR');
plot(s10, 'b', 'LineWidth', 1.3); hold on;
plot(indice, s10amostrado, 'o-r', 'LineWidth', 1.3);
stairs(indice, quantiza(s10amostrado, 2), 'm', 'LineWidth', 1.3);
title('Quantizacao 2 bits FLOOR'); grid on; hold off;
salvar('q1b_floor_2bits');

% --- 1.c) 2 bits ROUND
figure('Name', '1.c) Quantizacao 2 bits ROUND');
plot(s10, 'b', 'LineWidth', 1.3); hold on;
plot(indice, s10amostrado, 'o-r', 'LineWidth', 1.3);
stairs(indice, quantiza_round(s10amostrado, 2), 'm', 'LineWidth', 1.3);
title('Quantizacao 2 bits ROUND'); grid on; hold off;
salvar('q1c_round_2bits');

% --- 1.d) 5 bits FLOOR
figure('Name', '1.d) Quantizacao 5 bits FLOOR');
plot(s10, 'b', 'LineWidth', 1.3); hold on;
plot(indice, s10amostrado, 'o-r', 'LineWidth', 1.3);
stairs(indice, quantiza(s10amostrado, 5), 'm', 'LineWidth', 1.3);
title('Quantizacao 5 bits FLOOR'); grid on; hold off;
salvar('q1d_floor_5bits');

% --- 1.d) 5 bits ROUND
figure('Name', '1.d) Quantizacao 5 bits ROUND');
plot(s10, 'b', 'LineWidth', 1.3); hold on;
plot(indice, s10amostrado, 'o-r', 'LineWidth', 1.3);
stairs(indice, quantiza_round(s10amostrado, 5), 'm', 'LineWidth', 1.3);
title('Quantizacao 5 bits ROUND'); grid on; hold off;
salvar('q1d_round_5bits');

%% =========================================================
%% Q2 - Senoide 10Hz amostrada com varias taxas
%% =========================================================
fs_lista = [5, 15, 20, 20.01, 25, 40];

for fs = fs_lista
    Norig         = 200;                         % "continuo"
    s10original   = senoide(100, -100, 10, Norig);

    % numero de amostras = round(fs) garante vetor inteiro
    Na            = round(fs);
    s10amostrado2 = senoide(100, -100, 10, fs);  % senoide.m usa fa-1 em amostras
    % O exemplo do enunciado usa indice = 1:Norig/Na:Norig
    indice        = 1:Norig/Na:Norig;
    indice        = indice(1:length(s10amostrado2));

    % Tempo
    figure('Name', sprintf('Q2 seno 10Hz fs=%g', fs));
    plot(s10original, 'b'); hold on;
    plot(indice, s10amostrado2, 'r', 'LineWidth', 1.2);
    title(sprintf('Senoide 10Hz amostrada com fs = %g Hz', fs));
    xlabel('Amostras'); grid on; hold off;
    salvar(sprintf('q2_seno_%s_tempo', strrep(num2str(fs), '.', 'p')));

    % FFT
    figure('Name', sprintf('Q2 seno FFT fs=%g', fs));
    plot(abs(fft(s10amostrado2)), 'LineWidth', 1.2);
    title(sprintf('|FFT| do sinal amostrado com fs = %g Hz', fs));
    xlabel('Indice k'); grid on;
    salvar(sprintf('q2_seno_%s_fft', strrep(num2str(fs), '.', 'p')));
end

% Caso especial: 4000 amostras com fs=20.01 evidenciando o batimento
clear x;
for i = 1:4000
    x(i) = 100 * sin(2*pi*10*i/20.01);
end
figure('Name', 'Q2 batimento 20.01Hz');
plot(x, 'o-');
title('100 sin(2\pi 10 i / 20{,}01) com 4000 amostras (batimento ~0,01 Hz)');
xlabel('i'); grid on;
salvar('q2_batimento_2001');

%% =========================================================
%% Q3 - Cossenoide 10Hz amostrada com varias taxas
%% =========================================================
for fs = fs_lista
    Norig         = 200;
    c10original   = cossenoide(100, -100, 10, Norig);

    Na            = round(fs);
    c10amostrado2 = cossenoide(100, -100, 10, fs);
    indice        = 1:Norig/Na:Norig;
    indice        = indice(1:length(c10amostrado2));

    figure('Name', sprintf('Q3 cos 10Hz fs=%g', fs));
    plot(c10original, 'b'); hold on;
    plot(indice, c10amostrado2, 'r', 'LineWidth', 1.2);
    title(sprintf('Cossenoide 10Hz amostrada com fs = %g Hz', fs));
    xlabel('Amostras'); grid on; hold off;
    salvar(sprintf('q3_cos_%s_tempo', strrep(num2str(fs), '.', 'p')));

    figure('Name', sprintf('Q3 cos FFT fs=%g', fs));
    plot(abs(fft(c10amostrado2)), 'LineWidth', 1.2);
    title(sprintf('|FFT| da cossenoide amostrada com fs = %g Hz', fs));
    xlabel('Indice k'); grid on;
    salvar(sprintf('q3_cos_%s_fft', strrep(num2str(fs), '.', 'p')));
end

clear x;
for i = 1:4000
    x(i) = 100 * cos(2*pi*10*i/20.01);
end
figure('Name', 'Q3 batimento cos 20.01Hz');
plot(x, 'o-');
title('100 cos(2\pi 10 i / 20{,}01) com 4000 amostras');
xlabel('i'); grid on;
salvar('q3_batimento_cos_2001');

%% =========================================================
%% Q4 - Interpolacao de sinais via DFT
%% =========================================================
% --- Sinal SEM aliasing (5 Hz, 100 amostras)
clear x;
for n = 1:100
    x(n) = sin(2*pi*5*(n-1)/100);
end
energ_x = sum(x.*x);
fprintf('energ_x  = %.4f\n', energ_x);   % 50

figure('Name', 'Q4 sem aliasing'); set(gcf, 'Position', [100 100 900 700]);

subplot(3,2,1); plot(x, '.-');
title('sinal original sem aliasing'); grid on;

dftx = DFT(x);
subplot(3,2,2); plot(abs(dftx)); axis([0 50 -2 60]);
title('abs da DFT do sinal original'); grid on;

dftx(51:200) = complex(0,0);
y = IDFT(dftx);
energ_y = sum(y.*y);
fprintf('energ_y  = %.4f\n', energ_y);   % 12.5

subplot(3,2,3); plot(abs(dftx)); axis([0 200 -2 60]);
title('DFT com zeros'); grid on;

subplot(3,2,4); plot(y, '.-');
title('sinal reconstituido (mudanca na amplitude)'); grid on;

dftx2 = 4*dftx;
subplot(3,2,5); plot(abs(dftx2));
title('DFT preenchida com zeros e x4'); grid on;

ynew = IDFT(dftx2);
subplot(3,2,6); plot(ynew, '.-');
title('sinal reconstituido (com correcao da amplitude)'); grid on;

energ_ynew = sum(ynew.*ynew);
fprintf('energ_ynew = %.4f\n', energ_ynew); % 200
salvar('q4_sem_aliasing');

% --- Sinal COM aliasing (95 Hz amostrado a 100 Hz)
clear x xo;
for n = 1:500
    xo(n) = sin(2*pi*95*(n-1)/500);
end
indice1 = 1:5:500;
for n = 1:100
    x(n) = sin(2*pi*95*(n-1)/100);
end

figure('Name', 'Q4 com aliasing'); set(gcf, 'Position', [100 100 900 700]);

subplot(3,2,1);
plot(xo, '-r'); hold on;
plot(indice1, x, '.-b');
title('original 95Hz (vermelho) e aliasing 5Hz (azul)'); grid on; hold off;

dftx = DFT(x);
subplot(3,2,2); plot(abs(dftx)); axis([0 50 -2 60]);
title('abs da DFT do sinal amostrado'); grid on;

dftx(51:200) = 0 + 0i;
y = IDFT(dftx);

subplot(3,2,3); plot(abs(dftx)); axis([0 200 -2 60]);
title('DFT com zeros'); grid on;

subplot(3,2,4); plot(y, '.-');
title('reconstruido (inversao de fase, amplitude)'); grid on;

subplot(3,2,6); plot(abs(DFT(y)));
title('DFT do sinal reconstituido'); grid on;
salvar('q4_com_aliasing');

disp('Pratica 3 concluida. Figuras em ./imgs/.');
