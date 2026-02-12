function y = pmod_log(x, p)
%PMOD_LOG log model
    %y = p(1) .* log(x .* p(2) - p(3));
    y = p(1) .* log(p(2) * x);
end

