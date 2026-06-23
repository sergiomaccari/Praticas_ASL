function y = CalculaFPBIIR(fc, x)
% CALCULAFPBIIR  Filtro passa-baixas IIR de polo simples (analogo a um R-C).
%   y = CalculaFPBIIR(fc, x) filtra o vetor x com um polo simples cuja
%   frequencia de corte normalizada e fc (0 < fc < 0.5).
%
%   Coeficientes:  r = exp(-2*pi*fc);  a0 = 1 - r;  b1 = r;
%   Equacao de diferencas:  y[n] = a0*x[n] + b1*y[n-1]
    nx = length(x);
    r  = exp(-2*pi*fc);
    a0 = 1 - r;
    b1 = r;
    y = zeros(1, nx);
    y(1) = a0*x(1);
    for i = 2:nx
        y(i) = a0*x(i) + b1*y(i-1);
    end
end
