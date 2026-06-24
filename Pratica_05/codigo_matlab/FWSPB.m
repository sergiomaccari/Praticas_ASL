function H = FWSPB(M, FC)
% FWSPB  Filtro WindowSinc passa-baixas (FIR) com janela de Blackman.
%   H = FWSPB(M, FC) retorna os M coeficientes de um nucleo sinc janelado,
%   com frequencia de corte normalizada FC (0 < FC < 0.5). Ganho unitario
%   em corrente continua (soma dos coeficientes = 1).
    H = zeros(1, M);
    m2 = M/2;
    for i = 1:M
        if (i - m2) == 0
            H(i) = 2*pi*FC;                       % limite da sinc no centro
        else
            H(i) = sin(2*pi*FC*(i - m2)) / (i - m2);
        end
        w = 0.42 - 0.5*cos(2*pi*i/M) + 0.08*cos(4*pi*i/M);  % janela de Blackman
        H(i) = H(i) * w;
    end
    H = H / sum(H);                               % ganho unitario em DC
end
