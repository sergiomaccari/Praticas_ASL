function y = CalculaFPAIIR(fc, x)
% CALCULAFPAIIR  Filtro passa-altas IIR de polo simples (analogo a um R-C).
%   y = CalculaFPAIIR(fc, x) filtra o vetor x com a versao passa-altas do
%   polo simples, com frequencia de corte normalizada fc (0 < fc < 0.5).
%
%   Coeficientes:  r = exp(-2*pi*fc);  a0 = (1+r)/2;  a1 = -(1+r)/2;  b1 = r;
%   Equacao de diferencas:  y[n] = a0*x[n] + a1*x[n-1] + b1*y[n-1]
    nx = length(x);
    r  = exp(-2*pi*fc);
    a0 =  (1 + r)/2;
    a1 = -(1 + r)/2;
    b1 = r;
    y = zeros(1, nx);
    y(1) = a0*x(1);
    for i = 2:nx
        y(i) = a0*x(i) + a1*x(i-1) + b1*y(i-1);
    end
end
