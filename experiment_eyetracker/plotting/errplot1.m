function errplot1(results)

px_to_deg = 43.6/2560;
integration_time_ms = 1000 / 40;
integration_sample_count = round(integration_time_ms / 2);
field_names = {'target_cont_x', 'target_disp_x'};
mv = 20;
    trial_names = unique(results.trial_name);
    for iT=1:length(trial_names)
        for iF=1:length(field_names)
            
            
            subplot(2,length(trial_names), iT + (iF-1) * length(trial_names));
            trial_name = trial_names{iT};
            results_filt1 = results(strcmpi(trial_name, results.trial_name), :);
            observers = unique(results_filt1.observer_id);
            cols = lines(length(observers));
            for iO=1:length(observers)
                agg = cell(90, 1);
                results_filt2 = results_filt1(strcmpi(observers{iO}, results_filt1.observer_id),:);
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
                mus = nan(length(agg), 1);
                sigmas = mus;
                for ia=1:length(agg)
                    mus(ia) = mean(agg{ia});
                    sigmas(ia) = std(agg{ia});
                end
                velocities = 1 + (0:(length(agg) - 1))*3;
                plot(velocities, mus, 'Color', cols(iO,:));hold on;
                mv = max(velocities(find(~isnan(mus), 1, 'last')));
                h = area(velocities, [mus - sigmas, sigmas * 2]);
                h(1).FaceAlpha = 0;
                h(1).LineStyle = 'none';
                h(2).FaceAlpha = 0.5;
                h(2).FaceColor = cols(iO,:);
                hold on;
            end
            plot(velocities, velocities / 165, '--', 'Color', 'black');
            plot(velocities, velocities / 144, '--', 'Color', 'black');
            plot(velocities, velocities / 120, '--', 'Color', 'black');
            plot(velocities, velocities / 100, '--', 'Color', 'black');
            plot(velocities, velocities / 90, '--', 'Color', 'black');
            plot(velocities, velocities / 60, '--', 'Color', 'black');
            plot(velocities, velocities / mean(results.refresh_rate), '--', 'Color', 'black', 'LineWidth', 2);
            ylim([0, 0.8]);
            title(trial_names(iT));
            grid on;
        end
    end
    for ii=1:(2*length(trial_names))
        subplot(2,length(trial_names), ii);
        xlim([0, mv + 5]);
    end
end