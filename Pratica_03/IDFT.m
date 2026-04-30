function [y] = IDFT(x)
    nx = length(x);
    rex = real(x)/(nx);
    imx = -imag(x)/(nx);
    rex(1) = rex(1)/2;
    rex(nx) = rex(nx)/2;
    ny = 2*nx;
    yr(ny) = 0;
    yi(ny) = 0;
    for k = 1:nx
        for i = 1:ny
            yr(i) = yr(i) + rex(k)*cos(2*pi*(k-1)*(i-1)/ny);
            yi(i) = yi(i) + imx(k)*sin(2*pi*(k-1)*(i-1)/ny);
        end
    end
    y = yr + yi;
end
