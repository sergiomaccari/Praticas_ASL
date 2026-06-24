function y = FiltroRejeitaBanda(bw, f, x)
% FILTROREJEITABANDA  Filtro recursivo rejeita-banda (notch) de banda estreita.
%   y = FiltroRejeitaBanda(bw, f, x) atenua uma faixa estreita de largura bw
%   centrada na frequencia normalizada f (0 < f < 0.5).
%   (Projeto recursivo de 2a ordem - Smith, The Eng. Guide to DSP, cap. 19.)
    nx = length(x);
    r  = 1 - 3*bw;
    k  = (1 - 2*r*cos(2*pi*f) + r^2) / (2 - 2*cos(2*pi*f));
    a0 = k;
    a1 = -2*k*cos(2*pi*f);
    a2 = k;
    b1 = 2*r*cos(2*pi*f);
    b2 = -r^2;
    y = zeros(1, nx);
    y(1) = a0*x(1);
    y(2) = a0*x(2) + a1*x(1) + b1*y(1);
    for i = 3:nx
        y(i) = a0*x(i) + a1*x(i-1) + a2*x(i-2) + b1*y(i-1) + b2*y(i-2);
    end
end
