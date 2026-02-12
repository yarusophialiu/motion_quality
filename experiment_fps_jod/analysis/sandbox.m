res = load('scaled_results');
if isfield(res, 'res')
    res = res.res;
end
rr = 50:5:165;
for ii = 1:7
    P = convert_to_probs(@(r) pmod_log(r, res.log_p(ii,:)), rr);
    figure(ii);
    surf(rr, rr, P)
end
