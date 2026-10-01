res = load('scaled_results');
if isfield(res, 'res')
    res = res.res;
end

figure(1);
ii = 1;
refresh_rates = linspace(50,165, 10);
v = 15;
Q = norminv(convert_to_probs(@(r) pmod_log(r, res.log_p(ii,:)), refresh_rates), 0, 1.4826);
[fa, fb] = meshgrid(refresh_rates);
options = optimset('Display','iter');%, 'MaxFunEvals', 10000, 'MaxIter', 10000);
params = [0.06, 2, 1, 1];

%params2 = fminsearch(@(p) error(arrayfun(@(a,b) model_predict_prob_detect(a, b, v, 1, 0.2, p), fa, fb), Q, p), params, options);
params2 = fminsearch(@(p) err3(res.log_p, p, fa, fb, refresh_rates), params, options);

indices = [1, 2, 3, 5];
vs = [15, 30, 45, 23];
pred = [1, 1, 1, 0];
sp = {'unpredictable', 'predictable'};
for ii=1:length(indices)
    figure(ii);
    Q = norminv(convert_to_probs(@(r) pmod_log(r, res.log_p(indices(ii),:)), refresh_rates), 0, 1.4826);
    prediction = arrayfun(@(a,b) model_predict_Q(a, b, vs(ii), pred(ii), 1, 1, params2), fa, fb);
    surf(fa, fb, prediction); hold on;
    surf(fa, fb, Q, 'FaceColor', 'none', 'EdgeColor', 'red');
    hold off;
    title(sprintf('v = %ddps, %s', vs(ii), sp{pred(ii) + 1}));
end
    

function e = err3(log_ps, params, fa, fb, refresh_rates)
    indices = [1, 2, 3, 5];
    vs = [15, 30, 45, 23];
    pred = [1, 1, 1, 0];
    e = 0;
    for ii=1:length(indices)
        Q = norminv(convert_to_probs(@(r) pmod_log(r, log_ps(indices(ii),:)), refresh_rates),  0, 1.4826);
        e = e + error(arrayfun(@(a,b) model_predict_Q(a, b, vs(ii), pred(ii), 1, 1, params), fa, fb), Q, params);
    end
end


function e = error(P,Q ,params)
    % compute error as KL-Divergence
    %{
    logP = log(P);
    logQ = log(Q);
    e = abs( sum(sum(P .* (logP - logQ))) );
    %}
    if params(1) < 0 || ~isreal(P)
        e = 100000;
        return;
    end
    e = sqrt(mean(mean((P - Q) .^ 2)));
    
    % e = sqrt(mean(mean((P - Q) .^ 2))); % RMSE
    
    if params(1) < 0
        e = e + abs(params(1)) * 10000;
    end
end

