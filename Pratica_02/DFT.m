function [Y] = DFT(XX)
    N = length(XX);
    Y = zeros(1, N);

    for k = 0:(N-1)
        REX = 0;
        IMX = 0;
        for n = 0:(N-1)
            % Índices no MATLAB começam em 1
            REX = REX + XX(n+1) * cos(2*pi*k*n/N);
            IMX = IMX - XX(n+1) * sin(2*pi*k*n/N);
        end
        Y(k+1) = REX + 1i * IMX; 
    end
end