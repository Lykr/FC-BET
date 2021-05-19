function eMatrix = gen_eMatrix(n, angle)
    eMatrix = ones(n,1);
    
    for i = 1 : n
        eMatrix(i) = exp(1i * pi * (i - 1) * cos(angle));
    end
    
    eMatrix = 1 / sqrt(n) .* eMatrix;
end