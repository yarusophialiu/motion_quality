function P  = convert_to_probs(jodfun, refresh_rates)
%CONVERT_TO_PROBS sample JOD function and covert to refreshrate vs
%refreshrate probability space
    [fa, fb] = meshgrid(refresh_rates);
    JND = arrayfun(@(a,b) jodfun(a) - jodfun(b), fa, fb);
    
    P = normcdf(JND, 0, 1.4826);
end

