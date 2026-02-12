function run_initial_experiment_diff_stimuli_same_refresh_rate(exp_id, mock)

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
    
    all_exp_mat_name = strcat('./results/mat/mat_all_obs.mat');
    save_mat_name = strcat('./results/mat/mat_3_vel_',exp_id,'.mat');
    save_csv_name = strcat('./results/csv/csv_3_vel_',exp_id,'.csv');
    save_mat_all_exp = strcat('./results/mat/mat_3_vel_all_obs.mat');
    columns_names = {'exp_id','stimulus_1','stimulus_2','frequency_1','frequency_2','chose_1','chose_2'};
    table_res = cell2table(cell(0,numel(columns_names)),'VariableNames', columns_names);

    Ns = size(stimuli,1);

    if isfile(save_mat_all_exp)
        mat_file = load(save_mat_all_exp);
        M = mat_file.M;
    else
        all_exp_mat = load(all_exp_mat_name);
        M_tmp = (all_exp_mat.M);
        M1 = squeeze(M_tmp(1,:,:));
        M2 = squeeze(M_tmp(2,:,:));
        M3 = squeeze(M_tmp(3,:,:));
        M = zeros(72,72);
        M(1:24,1:24) = M1;
        M(25:48,25:48) = M2;
        M(49:72,49:72) = M3;
        
    end

    if isfile(save_mat_name)
        mat_file = load(save_mat_name);
        table_res = mat_file.table_res;
        pairs_to_compare = mat_file.pairs_to_compare;
        disp('Loaded results from file')
    else 
         [pairs_to_compare] = select_comps_same_rr();
    end
    
    % create the experiment presenter
    if mock
        presenter = MockPairwiseExperimentPresenter();
    else
        presenter = NetworkedPairwiseExperimentPresenter();
    end
    comparison_counter= 0;
    while numel(pairs_to_compare)>0
        comparison_counter = comparison_counter + 1;
        s_id = randi(size((pairs_to_compare),1),1);
        
        s_act_1 = pairs_to_compare(s_id,1);
        s_act_2 = pairs_to_compare(s_id,2);

        freq_1 = array_of_frequencies(pairs_to_compare(s_id,3));
        freq_2 = array_of_frequencies(pairs_to_compare(s_id,4));

        % request a comparison
        result = presenter.compare_cross_stimuli(freq_1, freq_2, stimuli(s_act_1) , stimuli(s_act_2), comparison_counter);
        if result == -1
            % early exit
            warning('experiment interrupted');
            presenter.experiment_finished(true);
            return;
        end

        matid_1 = (s_act_1-1)*24+pairs_to_compare(s_id,3);
        matid_2 = (s_act_2-1)*24+pairs_to_compare(s_id,4);
        % store experiment result
        if result
            new_row = cell2table(cell({exp_id, stimuli(s_act_1).id, stimuli(s_act_2).id,freq_1,freq_2,0,1}),'VariableNames', columns_names);
            M(matid_2,matid_1) = M(matid_2,matid_1)+1;
        else
            new_row = cell2table(cell({exp_id,stimuli(s_act_1).id,stimuli(s_act_2).id,freq_1,freq_2,1,0}),'VariableNames', columns_names);
            M(matid_1,matid_2) = M(matid_1,matid_2)+1;
        end



        pairs_to_compare(s_id,:) = [];
        table_res = [table_res;new_row];
        writetable(table_res, save_csv_name);
        save(save_mat_name,'pairs_to_compare','table_res','M');
        save(save_mat_all_exp,'M');


        disp(['Comparison ', num2str(comparison_counter),...
            ' Stimuli 1: ', num2str(stimuli(s_act_1).id),...
            ' Stimuli 2: ', num2str(stimuli(s_act_2).id),...
            ' Frequency 1: ', num2str(freq_1),...
            ' Frequency 2: ',...
            num2str(freq_2), ' Chose: ',  num2str(result),...
            ' ', num2str(matid_1),' ', num2str(matid_2)])
    end

    % experiment finished gracefully
    presenter.experiment_finished(false);
end
