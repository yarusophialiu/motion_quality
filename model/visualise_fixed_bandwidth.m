params = get_best_params();

figure(1);
max_res = 2560 * 1440;
max_refresh_rate = 165;
max_bandwidth = max_res * max_refresh_rate;
bandwidth = max_res * 30; % limited bandwidth

refresh_rates = 50:5:165;
resolution_reductions = min(1, sqrt(bandwidth ./ (refresh_rates * max_res)));

cols = lines();

vs = [0, 2 .^ (0:4)];
for iV=1:length(vs)
    QP = zeros(size(refresh_rates));
    QO = QP;
    for iR=1:length(refresh_rates)
        QP(iR) = model_predict_Q(refresh_rates(iR), refresh_rates(1), vs(iV), 1, resolution_reductions(iR), resolution_reductions(1), params); 
    end
    plot(refresh_rates, QP, 'Color', cols(iV,:)); hold on;
end
hold off;
xlabel('refresh rate')
ylabel('quality');
