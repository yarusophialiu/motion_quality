function run_initial_experiment(exp_id, mock)
    % run the initial experiment comparing different refresh rates
    if ~exist('exp_id', 'var') || isempty(exp_id)
        exp_id = 'TEST'; 
    end
    
    % run the initial experiment comparing different refresh rates
    if ~exist('mock', 'var') || isempty(mock)
        mock = false; 
    end    

    % load the potential stimuli
    stimuli = load_stimuli_from_file('Initial');

    array_of_frequencies = 50:5:165;
    budget_per_stimuli = 60;
    
    save_mat_name = strcat('./results/mat/mat_',exp_id,'.mat');
    save_csv_name = strcat('./results/csv/csv_',exp_id,'.csv');
    save_mat_all_exp = strcat('./results/mat/mat_all_obs.mat');
    columns_names = {'exp_id','stimulus','frequency_1','frequency_2','chose_1','chose_2'};
    table_res = cell2table(cell(0,numel(columns_names)),'VariableNames', columns_names);

    Ns = size(stimuli,1);

    if isfile(save_mat_all_exp)
        mat_file = load(save_mat_all_exp);
        M = mat_file.M;
    else
        M = zeros(Ns,numel(array_of_frequencies),numel(array_of_frequencies));
    end

    if isfile(save_mat_name)
        mat_file = load(save_mat_name);
        budget_for_stimuli = mat_file.budget_for_stimuli;
        stimuli_ar = mat_file.stimuli_ar;
        next_comp = mat_file.next_comp;
        table_res = mat_file.table_res;
        disp('Loaded results from file')
    else 
        stimuli_ar = [1:Ns];
        budget_for_stimuli = ones(1,Ns)*budget_per_stimuli;
        next_comp = [ones(Ns,1),ones(Ns,1)*2];
    end
    
    % create the experiment presenter
    if mock
        presenter = MockPairwiseExperimentPresenter();
    else
        presenter = NetworkedPairwiseExperimentPresenter();
    end
    
    comparison_counter = budget_per_stimuli * size(stimuli,1) - sum(budget_for_stimuli);
    while numel(stimuli_ar)>0
        comparison_counter = comparison_counter + 1;
        s_id = randi(numel(stimuli_ar),1);
        s_act = stimuli_ar(s_id);

        freq_1 = array_of_frequencies(next_comp(s_act,1));
        freq_2 = array_of_frequencies(next_comp(s_act,2));

        % request a comparison
        result = presenter.compare(freq_1, freq_2, stimuli(s_act), comparison_counter);
        if result == -1
            % early exit
            warning('experiment interrupted');
            presenter.experiment_finished(true);
            return;
        end

        % store experiment result
        if result
            new_row = cell2table(cell({exp_id, stimuli(s_act).id,freq_1,freq_2,0,1}),'VariableNames', columns_names);
            M(s_act,next_comp(s_act,2),next_comp(s_act,1)) = M(s_act,next_comp(s_act,2),next_comp(s_act,1))+1;
        else
            new_row = cell2table(cell({exp_id,stimuli(s_act).id,freq_1,freq_2,1,0}),'VariableNames', columns_names);
            M(s_act,next_comp(s_act,1),next_comp(s_act,2)) = M(s_act,next_comp(s_act,1),next_comp(s_act,2))+1;
        end


        next_comp(s_act,:) = get_next_comparison(squeeze(M(s_act,:,:)));

        budget_for_stimuli(s_id) = budget_for_stimuli(s_id)-1;
        if budget_for_stimuli(s_id)==0
            budget_for_stimuli(s_id) = [];
            stimuli_ar(s_id) = [];
        end

        table_res = [table_res;new_row];
        writetable(table_res, save_csv_name);
        save(save_mat_name,'budget_for_stimuli','stimuli_ar','next_comp','table_res','M');
        save(save_mat_all_exp,'M');


        disp(['Comparison ', num2str(comparison_counter) ' Stimuli: ', num2str(stimuli(s_act).id), ' Frequency 1: ', num2str(freq_1),' Frequency 2: ', num2str(freq_2), ' Chose: ',  num2str(result)])
    end

    % experiment finished gracefully
    presenter.experiment_finished(false);
end
