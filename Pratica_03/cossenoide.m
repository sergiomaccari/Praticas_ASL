%% uso: cossenoide(vp, vn, f, fa)
%%
%% Gera uma onda cossenoidal de frequencia 'f' (Hz), valor de pico
%% positivo 'vp' (V), valor de pico negativo 'vn' (V) e taxa
%% de amostragem 'fa' (amostras por segundo).

function [Y] = cossenoide(vp, vn, f, fa)
    amostras  = 0:(fa-1);
    amplitude = (vp - vn)/2;
    Y0        = (vp + vn)/2;
    Y         = Y0 + amplitude * cos(2*pi*f*amostras/fa);
end
