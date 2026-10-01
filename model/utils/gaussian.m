function y = gaussian(x, mu, sigma, A)
%GAUSSIAN gaussian bell curve
    y = A * exp(-1/2 * ((x - mu) / sigma) .^ 2);
end

