function [y] = DFT(x) % by cesar  janeczko em 1sem2025
    nx=length(x);
    y(floor(nx/2)+1)=0;
    i=sqrt(-1);
    for k=1:(nx/2)+1% frequencia k
        for j=1:nx
            y(k)=y(k)+ x(j)*exp(-i*2*pi*(k-1)*(j-1)/nx);
            % a exponencial contem seno e cosseno Euller
        end
    end
end