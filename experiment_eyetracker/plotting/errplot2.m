function errplot2(results)
clf;
refresh_rates = unique(results.refresh_rate);
px_to_deg = 43.6/2560;
integration_time_ms = 1000 / 40;
integration_sample_count = round(integration_time_ms / 2);
field_names = {'target_cont_x', 'target_cont_x', 'target_disp_x'};
mv = 20;
    trial_names = unique(results.trial_name);
    for iT=1:length(trial_names)
        for iF=1:length(field_names)
            subplot(3,length(trial_names), iT + (iF-1) * length(trial_names));
            trial_name = trial_names{iT};
            results_filt1 = results(strcmpi(trial_name, results.trial_name), :);
            cols = lines(length(refresh_rates));
            for iR=1:length(refresh_rates)
                agg = cell(90, 1);
                results_filt2 = results_filt1(results_filt1.refresh_rate ==  refresh_rates(iR),:);
                for ii=1:size(results_filt2, 1)
                    mask = logical(results_filt2.object(ii).Samples.mask);
                    slot = round((1:length(mask)) / integration_sample_count)';
                    for jj=1:slot(end)
                        mask2 = find(mask & (slot == jj));
                        if isempty(mask2)
                            continue;
                        end
                        v = px_to_deg * mean(abs(results_filt2.object(ii).Samples.target_cont_vx(mask2)));
                        bucket = 1 + round(v / 3) * 3;
                        poss = px_to_deg * (results_filt2.object(ii).Samples.posX(mask2) - ...
                                results_filt2.object(ii).Samples.(field_names{iF})(mask2));
                        smear = max(poss) - min(poss);
                        agg{bucket} =[agg{bucket}, smear];
                    end
                end
                agg = agg(1:3:end);
                mus = cellfun(@(x) mean(x), agg);
                velocities = 1 + (0:(length(agg) - 1))*3;
                k = 100;
                if iF == 2
                    %preds = log(exp(k * mus) + exp(k * velocities' / refresh_rates(iR))) / k;
                    sums = mus + velocities' / refresh_rates(iR);
                    preds = (mus ./ sums) .* sums + (1 - mus ./ sums) .* velocities' / refresh_rates(iR);
                    plot(velocities, preds, 'Color', cols(iR,:));hold on;
                else
                    plot(velocities, mus, 'Color', cols(iR,:));hold on;
                end
                hold on;
            end
            ylim([0, 0.8]);
            title(trial_names(iT));
            if iT == 1 && iF == 1
                 legend(string(refresh_rates), 'Location', 'NorthWest');
            end
            if mod(iF, 3) ~= 1
                for iR=1:length(refresh_rates)
                    plot(velocities, velocities / refresh_rates(iR), '--', 'Color', cols(iR,:));
                end
            end
            grid on;
        end
    end
    for ii=1:(3*length(trial_names))
        subplot(3,length(trial_names), ii);
        xlim([0, mv + 5]);
    end
    hold off;
end