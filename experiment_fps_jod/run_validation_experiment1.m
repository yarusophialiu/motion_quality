function run_validation_experiment1(exp_id, mock)
    % run the validation experiment comparing our technique to different refresh rates
    if ~exist('exp_id', 'var') || isempty(exp_id)
        exp_id = 'TEST'; 
    end
    
    if ~exist('mock', 'var') || isempty(mock)
        mock = false; 
    end    

    % load the potential stimuli
    stimuli = load_stimuli_from_file('Validation1');
    bandwidths = [27648000, 55296000, 221184000]; %[0.05, 0.1, 0.2, 0.3, 0.5] * full_bandwidth; 
    base_rrs = [36, 51, 90];
    base_rrs = [base_rrs; base_rrs * 1.5; base_rrs / 1.5]';
    vs = 0:40;
    refresh_rates = zeros(length(vs), length(bandwidths));
    for iB=1:length(bandwidths)
        for iV=1:length(vs)
            rrs = 50:165;
            vals = arrayfun(@(p) objective_function(150, p, bandwidths(iB), 2560*1440, vs(iV)), rrs);
            [~, i] = min(vals);
            refresh_rates(iV,iB) = rrs(i);
        end
        refresh_rates(1,iB) = max(32, bandwidths(iB) / (2560 * 1440));
    end
    %plot(vs, refresh_rates); 
    
    
    stimulus_set = get_validation1_ss(bandwidths, base_rrs);
    save_csv_name = strcat('./results/csv/csv_val_',exp_id,'.csv');
    columns_names = {'exp_id','trial_id','stimulus','bandwidth','frequency','chose_1','chose_2'};
    table_res = cell2table(cell(0,numel(columns_names)),'VariableNames', columns_names);
    
    % attempt to load previous results
    if exist(save_csv_name, 'file')
        table_res = readtable(save_csv_name);
        disp('Loaded results from file')
        keep_mask = ones(length(stimulus_set),1);
        for ii=1:size(table_res, 1)
            keep_mask(table_res.trial_id(ii)) = 0;
        end
        stimulus_set = stimulus_set(logical(keep_mask));
    end
    
    % randomise
    stimulus_set = stimulus_set(randperm(length(stimulus_set)));
    
    % create the experiment presenter
    if mock
        presenter = MockPairwiseExperimentPresenter();
    else
        presenter = NetworkedPairwiseExperimentPresenter();
    end
    
    comparison_counter = size(table_res,1);
    for iT=1:length(stimulus_set)
        comparison_counter = comparison_counter + 1;
        active_scene_index = randi([1, length(stimuli)]);   % pick a scene randomly
        bandwidth = bandwidths(stimulus_set(iT).bandwidth);
        frequency = stimulus_set(iT).refresh_rate;
        LUT = refresh_rates(:,stimulus_set(iT).bandwidth);
        result = presenter.compare(-1, frequency, stimuli(active_scene_index), comparison_counter, bandwidth, LUT);
        if result == -1
            % early exit
            warning('experiment interrupted');
            presenter.experiment_finished(true);
            return;
        end
        
        if result
            new_row = cell2table(cell({exp_id, stimulus_set(iT).id, stimuli(active_scene_index).id, bandwidth,frequency,0,1}),'VariableNames', columns_names);
        else
            new_row = cell2table(cell({exp_id, stimulus_set(iT).id, stimuli(active_scene_index).id, bandwidth,frequency,1,0}),'VariableNames', columns_names);
        end
        table_res = [table_res;new_row];
        writetable(table_res, save_csv_name);
        disp(['Comparison ', num2str(comparison_counter),...
            ' Chose: ',  num2str(result)]);
        
        pause(1); % wait for display information (trial count)
    end

    % experiment finished gracefully
    presenter.experiment_finished(false);
end


function e = objective_function(base_rr, rr, bandwidth, max_res, v)
    params = get_best_params();
    params(4) = params(2) * 2.2;
    resolution_reduction_base = min(1, sqrt(bandwidth ./ (base_rr * max_res)));
    resolution_reduction = min(1, sqrt(bandwidth ./ (rr * max_res)));
    
    e = -model_predict_Q(rr, base_rr, v, 1, resolution_reduction, resolution_reduction_base, params);     
    % apply constraints
    e = e + max(20 - rr, 0) * 100 + max(rr - 165, 0) * 100;
    
    % promote higher refresh rates when flat
    e = e - (rr) * 0.00001;
end
