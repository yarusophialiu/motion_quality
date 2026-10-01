anchor = 1;
model_mask = [1, 1, 1, 1];
%[QJ, QP, QO, predictability]

res = load('scaled_results');
if isfield(res, 'res')
    res = res.res;
end
res.JODs(1:3,:) = res.JODs3(:,:);
for ii=1:7
    res.JODs(ii,:) = res.JODs(ii,:) - res.JODs(ii,anchor);
end


figure(1);
options = optimset('Display','iter');%, 'MaxFunEvals', 800, 'MaxIter', 10000);
params =   [0.002168509793548   1.457642988570985   1.740822575158929   2.186464482856478 2]; %[0.001, 2, 1, 1,    1.1];

[params2, e] = fminsearch(@(p) err3(p, res, anchor, model_mask), params, options);
e
%params2(1) = 0.001;
params2(4) = params2(2) * 1.5;

indices = [1, 2, 3, 5];
vs = [15, 30, 45, 23];
pred = [1, 1, 1, 0];
sp = {'unpredictable', 'predictable'};
for ii=1:length(indices)
    figure(ii);
    Q = res.JODs(indices(ii),:);
    P = arrayfun(@(f) model_predict_Q(f, res.refresh_rates(anchor), vs(ii), pred(ii), 1, 1, params2), res.refresh_rates);
    %P = P - P(anchor);
    P = P + mean(Q) - mean(P);
    plot(res.refresh_rates, Q, 'x', 'Color', 'red'); hold on;
    plot(res.refresh_rates, P, 'Color', 'blue'); hold on;
    hold off;
    title(sprintf('v = %ddps, %s', vs(ii), sp{pred(ii) + 1}));
end
params2


figure(5);
P = arrayfun(@(f) model_predict_Q(f, res.refresh_rates(anchor), 45, 1, 1, 1, params2), 50:500);
plot( 50:500, P, 'Color', 'blue');
    

function e = err3(params, res, anchor, model_mask)
    indices = [1, 2, 3, 5];
    vs = [15, 30, 45, 23];
    pred = [1, 1, 1, 0];
   % params(1) = 0.001;
    e = 0;
    params(4) = params(2) * 1.5;
    for ii=1:length(indices)
        Q = res.JODs(indices(ii),:);
        P = arrayfun(@(f) model_predict_Q(f, res.refresh_rates(anchor), vs(ii), pred(ii), 1, 1, params, model_mask), res.refresh_rates);
        %P = P - P(anchor);
        e = e + error(P, Q, params) .^ 2;
    end
    e = sqrt(e/length(indices));
    
    %if (params(1) < 1)
    %    e = e + abs(1 - params(1)) * 1000000;
    %end
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
    Q = Q + mean(P) - mean(Q);
    e = sqrt(mean(mean((P - Q) .^ 2)));
    
    % e = sqrt(mean(mean((P - Q) .^ 2))); % RMSE
    
    for ii=1:3
        if params(ii) < 0
            e = e + abs(params(ii)) * 10000;
        end
    end
    
end
