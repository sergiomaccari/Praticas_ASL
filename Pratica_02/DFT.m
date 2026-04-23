function [Y] = DFT(XX)

    N = length(XX);
    
    for K = 0:(N-1)
        REX = 0;
        IMX = 0;

        for I = 0:(N-1)
            REX = REX + XX(I+1) * cos(2 * pi * K * I / N);
            IMX = IMX - XX(I+1) * sin(2 * pi * K * I / N);
        end

        Y(K+1) = REX + sqrt(-1) * IMX;

    end

end