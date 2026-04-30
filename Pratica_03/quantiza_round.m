function [Xam] = quantiza_round(x, M)
    Xam = round(x / 2^(8-M)) * 2^(8-M);
end
