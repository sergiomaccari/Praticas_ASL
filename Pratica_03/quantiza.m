function [Xam] = quantiza(x, M)
    Xam = floor(x / 2^(8-M)) * 2^(8-M);
end
