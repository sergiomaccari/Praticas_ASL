function [Y] = DFT(XX)
    NX = length(XX);
    REX(floor(NX/2) + 1) = 0;
    IMX(floor(NX/2) + 1) = 0;
    for K = 1:(floor(NX/2) + 1)
        for I = 1:NX
            REX(K) = REX(K) + XX(I) * cos(2 * pi * (K-1) * (I-1) / NX);
            IMX(K) = IMX(K) - XX(I) * sin(2 * pi * (K-1) * (I-1) / NX);
        end
        Y = REX + sqrt(-1) * IMX;
    end
end