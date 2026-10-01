res = load('scaled_results');
if isfield(res, 'res')
    res = res.res;
end

params = get_best_params(); % BEST FIT

for ii=1:3
    figure(ii);
    refresh_rates = 50:5:165;
    v = 15 * ii;
    JNDs = norminv(convert_to_probs(@(r) pmod_log(r, res.log_p(ii,:)), refresh_rates), 0, 1.4826);
    [fa, fb] = meshgrid(refresh_rates);
    pred =  arrayfun(@(a,b) model_predict_Q(a, b, v, 1, 1, 1, params), fa, fb);
    surf(fa, fb, pred); hold on;
    surf(fa, fb, JNDs, 'FaceColor', 'none', 'EdgeColor', 'red');
    hold off;
    title(sprintf('v = %ddps', v));
    hold off;
    
end
